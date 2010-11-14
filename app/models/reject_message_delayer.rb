class RejectMessageDelayer
  @queue = :timeouts

  def self.perform(args_hash)
    user_id = args_hash["user_id"]
    user = User.find(user_id)
    user.handle_no_responses
  end
end
