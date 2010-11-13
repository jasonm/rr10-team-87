class ProfileAnnoyer
  @queue = :annoyer

  def self.perform(args_hash)
    user_id = args_hash["user_id"]
    user = User.find(user_id)

    if user.incomplete?
      user.tell("Hey you need to fill out your instalover profile! Go back and entre your phone number, or quit forever with 'safeword'.")
      QUEUE.enqueue_at(1.day.from_now, ProfileAnnoyer, :user_id => user.id)
    end
  end
end
