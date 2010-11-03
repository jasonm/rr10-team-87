class Offerizer
  @queue = :offers

  def self.perform(args_hash)
    meetup = Meetup.find(args_hash['meetup_id'])
    user = User.find(args_hash['user_id'])

    user.matching.first(5).each do |matching_user|
      Offer.create(:offered_user => matching_user, :meetup => meetup)
    end
    #QUEUE.enqueue_at(5.minutes.from_now, RejectMessageDelayer, :user_id => user.id)
    QUEUE.enqueue_at(5.minutes.from_now, Offerizer, :user_id => user.id, :meetup_id => meetup.id)
  end
end
