class Offer < ActiveRecord::Base
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

  private

  def send_message
    Message.deliver(offered_user.phone_number,
      "Want to go on a date with #{meetup.first_user.name} at #{meetup.description}? Reply 'accept' or ignore.")
  end
end
