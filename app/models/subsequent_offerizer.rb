class SubsequentOfferizer
  @queue = :offers

  def self.perform(args_hash)
    meetup = Meetup.find(args_hash['meetup_id'])
    user = User.find(args_hash['user_id'])

    meetup.cancel_pending_offers
    Offer.create_for_meetup_and_users(meetup, user.matching.first(5))
    user.tell("We're still looking for a date for you, back in five.")

    QUEUE.enqueue_at(5.minutes.from_now, SubsequentOfferizer,
                     :user_id => user.id,
                     :meetup_id => meetup.id)
  end
end
