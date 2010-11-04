class Offer < ActiveRecord::Base
  # pending:  the date requestor has not accepted yet
  # declined: the other offers won the bidding
  # accepted: the date is happening
  # canceled: the date requestor denied the offer
  STATES = %w(pending declined accepted canceled)
  belongs_to :meetup
  belongs_to :offered_user, :class_name => "User"

  after_create :send_message
  after_create :create_event

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

  def event_from
    meetup.try(:first_user).try(:name)
  end

  def event_to
    offered_user.try(:name)
  end

  def information
    meetup.description
  end

  private

  def send_message
    Message.deliver(offered_user.phone_number,
      "Want to go on a date with #{meetup.first_user.name} at #{meetup.description}? Reply '#{COMMANDS[:accept]}' or ignore.")
  end

  def create_event
    Event.create(
      :kind        => "Offer",
      :actor       => meetup.try(:first_user).try(:identifier),
      :subject     => offered_user.try(:identifier),
      :description => meetup.try(:description),
      :created_at  => meetup.try(:updated_at),
      :updated_at  => meetup.try(:updated_at)
    )
  end
end
