class MorningAfterCheckerUpper

  def self.perform(args_hash)
    meetup_id = args_hash["meetup_id"]

    if ! Meetup.exists?(meetup_id)
      raise "MorningAfterCheckerUpper ran for meetup_id #{args_hash["meetup_id"]} but could not find that meetup"
    end

    meetup = Meetup.find(meetup_id)

    Message.deliver(meetup.first_user.phone_number,
      "Hey #{meetup.first_user.name}, how did it go last night with #{meetup.second_user.name}?  Respond to this text to let us know.")

    Message.deliver(meetup.second_user.phone_number,
      "Hey #{meetup.second_user.name}, how did it go last night with #{meetup.first_user.name}?  Respond to this text to let us know.")

    Dfln.create(:user => meetup.first_user,  :text => nil)
    Dfln.create(:user => meetup.second_user, :text => nil)
  end
end
