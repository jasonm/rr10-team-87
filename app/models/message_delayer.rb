class MessageDelayer
  @queue = :timeouts

  def self.perform(args_hash)
    user_id = args_hash["user_id"]
    user = User.find(user_id)
    Message.handle_no_responses(user)
  end
end
