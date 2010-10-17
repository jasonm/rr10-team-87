class MessageSender < Resque::Plugins::RestrictionJob
  restrict :per_minute => 10

  def self.perform(uri_string)
    Net::HTTP.get(URI.parse(uri_string))
  end
end
