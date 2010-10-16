require 'sinatra'

module FakeTropo
  class Response
    @@responses = []

    def self.add!(response)
      @@responses << response
    end

    def self.last
      @@responses.last
    end

    def self.has_text?(phone, message)
      puts "Message Texts:"
      @@responses.any? do |r|
        p r
        r["to"] == phone && r["message"] == message
      end
    end
  end
end

get '/1.0/sessions' do
  FakeTropo::Response.add!(params)
  '<success>true</success>'
end

ShamRack.at('api.tropo.com').rackup do
  run Sinatra::Application
end
