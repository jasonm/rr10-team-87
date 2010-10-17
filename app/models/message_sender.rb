class MessageSender < Resque::Plugins::RestrictionJob
  restrict :per_minute => 10

  @queue = :messages

  def self.perform(uri_string)
    Rails.logger.info "Running SMS: GET #{uri_string}"
    Net::HTTP.get(URI.parse(uri_string))
  end
end
