class Offer < ActiveRecord::Base
  belongs_to :meetup
  belongs_to :offered_user, :class_name => "User"

  after_create :send_message

  private

  def send_message
    Message.deliver(offered_user.phone_number,
      "Want to go on a date with #{meetup.first_user.name} at #{meetup.description}? Reply 'accept' or ignore.")
  end
end
