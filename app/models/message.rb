require 'net/http'
require 'addressable/uri'
require 'uri'

class Message < ActiveRecord::Base

  TROPO_URL = "http://api.tropo.com/1.0"
  MESSAGE_TOKEN = "aeea3bf2048d1848bc4e706ff76bfe98951f433968b934a2a1d80cf1e047ba36c91a2cd53a958e15319a564a"

  def self.deliver(to, message)
    params = Addressable::URI.new
    params.query_values = {
      "relay" => "relay",
      "to" => to,
      "message" => message,
      "token" => MESSAGE_TOKEN,
      "action" =>"create"
    }
    param_string = params.query
    uri = URI.parse("#{TROPO_URL}/sessions?#{param_string}")
    response = Net::HTTP.get(uri)

    if response.include?("<success>true</success>")
      true
    else
      raise "Failed to text, to=#{to}, message=#{message}:\n#{response.inspect}"
    end

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
    user = User.find_by_phone_number(phone_number)

    if user.nil?
      Message.deliver(phone_number,
                      "You must register first at instalover.com")
      return
    end

    message_text = message_text.downcase
    if message_text == 'new date'
      handle_new_date(user)
    elsif message_text == 'ok'
      handle_ok(user)
    elsif message_text == 'accept'
      handle_accept(user)
    elsif message_text =~ /^say (.*)/i
      handle_texting_proxy(user, $1)
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
    user.founded_meetups.proposed.destroy_all

    # Uncomment later
    # if user.meetups.unscheduled.any?
    #   Message.deliver(user.phone_number,
    #                   "Hold tight already!")
    #   return
    # end

    user.offers.destroy_all

    meetup = Meetup.create({
      :first_user => user,
      :description => DateSuggestion.next_place_and_time
    })


    Message.deliver(user.phone_number,
                    "How about #{meetup.description}? Reply 'ok' or 'new date'.")
  end

  def self.handle_ok(user)
    meetup = user.founded_meetups.proposed.first
    if meetup
      meetup.unschedule!
      user.matching.each do |matching_user|
        if matching_user.founded_meetups.proposed.none?
          puts "Found a match for #{user.phone_number} at #{matching_user.phone_number}"
          Offer.create(:offered_user => matching_user, :meetup => meetup)
        end
      end
    else
      handle_unknown(user)
    end
  end

  def self.handle_unknown(user)
      Message.deliver(user.phone_number,
                      "Please text 'new date' for a new date. To stop receiving texts, please text 'safeword'")

  end

  def self.handle_accept(user)
    if user.offers.none?
      Message.deliver(user.phone_number,
                      "You don't have any date offers to accept")
    else
      user.offers.first.meetup.offers.each do |o|
        if o.offered_user.id == user.id
          o.meetup.second_user = o.offered_user
          o.meetup.save!
          Message.deliver(o.offered_user.phone_number,
                          "You got it! Meet at #{o.meetup.description}. Your date is: '#{o.meetup.first_user.description}'")
          Message.deliver(o.meetup.first_user.phone_number,
                          "You got it! Meet at #{o.meetup.description}. Your date is: '#{o.meetup.second_user.description}'")
        else
          Message.deliver(o.offered_user.phone_number,
                          "Too slow! Would you like to get a date? Reply 'new date'.")
        end
        o.delete
      end
    end
  end

end
