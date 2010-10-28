class Offer < ActiveRecord::Base
  # pending:  the date requestor has not accepted yet
  # declined: the other offers won the bidding
  # accepted: the date is happening
  # canceled: the date requestor denied the offer
  STATES = %w(pending declined accepted canceled)
  belongs_to :meetup
  belongs_to :offered_user, :class_name => "User"

  after_create :send_message

  def self.pending
    where('state = "pending"')
  end

  def self.cancel_all
    all.each(&:cancel!)
  end

  def accept!
    self.state = 'accepted'
    self.save!
  end

  def cancel!
    self.state = 'canceled'
    self.save!
  end

  def decline!
    self.state = 'declined'
    self.save!
  end

  def schedule_meetup!
    self.meetup.schedule_with!(self.offered_user)
  end

  private

  def send_message
    Message.deliver(offered_user.phone_number,
      "Want to go on a date with #{meetup.first_user.name} at #{meetup.description}? Reply '#{COMMANDS[:accept]}' or ignore.")
  end
end
