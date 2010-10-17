require 'net/http'
require 'addressable/uri'
require 'uri'

class Message < ActiveRecord::Base

  TROPO_URL = "http://api.tropo.com/1.0"
  MESSAGE_TOKEN = "aeea3bf2048d1848bc4e706ff76bfe98951f433968b934a2a1d80cf1e047ba36c91a2cd53a958e15319a564a"
  DATING_START_STRING = '1PM EDT'
  DATING_END_STRING = '10:59PM EDT'
  DATING_START = Time.parse(DATING_START_STRING)
  DATING_END = Time.parse(DATING_END_STRING)

  def self.deliver(to, message)
    Rails.logger.info "Enqueued SMS: TO: #{to}: #{message}"

    params = Addressable::URI.new
    params.query_values = {
      "relay" => "relay",
      "to" => to,
      "message" => message,
      "token" => MESSAGE_TOKEN,
      "action" =>"create"
    }
    param_string = params.query

    QUEUE.enqueue(MessageSender, "#{TROPO_URL}/sessions?#{param_string}")
  end

  def self.json_for_relay(message_params)
    to = message_params[:to]
    message = message_params[:message]

    tropo = Tropo::Generator.new do
      message({
        :to => 'tel:+' + to,
        :channel => 'TEXT',
        :network => 'SMS'
      }) do
        say :value => message
      end
    end

    tropo.response
  end

  def self.handle_incoming(phone_number, message_text)
    Rails.logger.info("SMS INCOMING: FROM #{phone_number}: #{message_text}")

    user = User.find_by_phone_number(phone_number)

    if user.nil?
      Message.deliver(phone_number,
                      "Sorry, you must register first at instalover.com")
      return
    end

    if user.unconfirmed?
      user.deliver_secret_code
      return
    end

    if user.dflns.unwritten.any?
      handle_dfln(user, message_text)
      return
    end

    if message_text =~ /new.*date/i
      handle_new_date(user)
    elsif message_text =~ /ok/i
      handle_ok(user)
    elsif message_text =~ /accept/i
      handle_accept(user)
    elsif message_text =~ /^say (.*)/i
      handle_texting_proxy(user, $1)
    elsif message_text =~ /safeword/i
      handle_safeword(user)
    else
      handle_unknown(user)
    end
  end

  def self.handle_texting_proxy(user, message)
    if dating_user = user.date
      Message.deliver(user.date.phone_number, "Your date says: #{message}")
    else
      Message.deliver(user.phone_number, "You have no date for us to share that with. Reply with 'new date'.")
    end
  end

  def self.handle_new_date(user)
    if within_dating_hours?
      user.founded_meetups.proposed.destroy_all

      if user.founded_meetups.unscheduled.any?
        Message.deliver(user.phone_number,
                        "Whoa there, partner - we're looking for someone right now.  If nobody shows after 5 minutes, then you can ask again.")
      else
        user.offers.destroy_all

        meetup = Meetup.create({
          :first_user => user,
          :description => DateSuggestion.next_place_and_time
        })


        Message.deliver(user.phone_number,
                        "How about #{meetup.description}? Reply 'ok' or 'new date'.")
        QUEUE.enqueue_at(5.minutes.from_now, OkTimeoutMessageDelayer, :user_id => user.id)
      end
    else
      outside_dating_hours(user)
    end
  end

  def self.within_dating_hours?
    now = Time.now
    now.hour >= DATING_START.hour &&
      now.hour <= DATING_END.hour
  end

  def self.outside_dating_hours(user)
    Message.deliver(user.phone_number,
                    "Outside of the dating hours: #{DATING_START_STRING} to #{DATING_END_STRING}. Please try again then!")
  end

  def self.handle_ok(user)
    meetup = user.founded_meetups.proposed.first
    if meetup
      meetup.unschedule!
      user.matching.first(5).each do |matching_user|
        Offer.create(:offered_user => matching_user, :meetup => meetup)
      end
      QUEUE.enqueue_at(5.minutes.from_now, RejectMessageDelayer, :user_id => user.id)
    else
      handle_unknown(user)
    end
  end

  def self.handle_unknown(user)
      Message.deliver(user.phone_number,
          "Sorry, I don't know what to do with that. You can text 'new date' to get a date. To stop receiving texts, please text 'safeword'")

  end

  def self.handle_accept(user)
    if user.offers.none?
      Message.deliver(user.phone_number,
                      "You don't have any date offers to accept")
    else
      user.offers.first.meetup.offers.each do |o|
        if o.offered_user.id == user.id
          o.meetup.state = 'scheduled'
          o.meetup.second_user = o.offered_user
          o.meetup.save!
          Message.deliver(o.offered_user.phone_number,
                          %{Nice! You've got a date with #{o.meetup.first_user.name}, whose self-description is: '#{o.meetup.first_user.description}'. Talk with your date by texting 'say ' with your message})
          Message.deliver(o.meetup.first_user.phone_number,
                          %{Nice! You've got a date with #{o.meetup.second_user.name}, whose self-description is: '#{o.meetup.second_user.description}'. Talk with your date by texting 'say ' with your message})
        else
          Message.deliver(o.offered_user.phone_number,
                          "Too slow! Would you like to get a date? Reply 'new date'.")
        end
        o.delete
      end
    end
  end

  def self.handle_safeword(user)
    Message.deliver(user.phone_number,
      "I got it - 'no' means no!  We could just be friends, but we're not fooling anyone.  You're unsubscribed - have a nice life!")
    user.destroy
  end

  def self.handle_dfln(user, message)
    dfln = user.dflns.unwritten.last
    dfln.update_attributes({
      :text => message
    })
  end

  def self.handle_no_responses(user)
    meetup = user.founded_meetups.unscheduled.first
    if !meetup.nil?
      Message.deliver(user.phone_number,
                      "We called every number in our little black book, but only got answering machines.  Try again later?  Reply 'new date' to start again.")
      meetup.offers.each do |o|
        Message.deliver(o.offered_user.phone_number,
                        "Too slow! Would you like to get a date? Reply 'new date'.")
        o.delete
      end
      meetup.state = "cancelled"
      meetup.save!
    end
  end

  def self.handle_ok_timeout(user)
    meetup = user.founded_meetups.proposed.first
    if !meetup.nil?
      Message.deliver(user.phone_number,"I guess you don't want to go on a date... Text 'new date' again when you change your mind")
      meetup.state == "cancelled"
    end
  end
end
