require 'net/http'
require 'addressable/uri'
require 'uri'

class Message < ActiveRecord::Base

  TROPO_URL = "http://api.tropo.com/1.0"
  MESSAGE_TOKEN = "aeea3bf2048d1848bc4e706ff76bfe98951f433968b934a2a1d80cf1e047ba36c91a2cd53a958e15319a564a"

  def self.deliver(to, message)
    params = Addressable::URI.new
    params.query_values = {
      "relay" => true,
      "to" => to,
      "message" => message,
      "token" => MESSAGE_TOKEN,
      "action" =>"create"
    }
    param_string = params.query
    uri = URI.parse("#{TROPO_URL}/sessions?#{param_string}")
    response = Net::HTTP.get(uri)

    if response.include?("<success>true</success>")
      true
    else
      raise "Failed to text, to=#{to}, message=#{message}:\n#{response.inspect}"
    end

  end

  def self.json_for_relay(message_params)
    to = message_params[:to]
    message = message_params[:message]

    tropo = Tropo::Generator.new do
      message({
        :to => 'tel:+1' + to,
        :channel => 'TEXT',
        :network => 'SMS'
      }) do
        say :value => message
      end
    end

    tropo.response
  end

end
