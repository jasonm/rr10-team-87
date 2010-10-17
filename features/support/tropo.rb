require 'sinatra'

module FakeTropo
  class Response
    @@responses = []

    def self.add!(response)
      @@responses << response
    end

    def self.clear_all
      @@responses = []
      Rails.logger.info "SMS: --------- RESET ---------"
    end

    def self.all
      @@responses
    end

    def self.last
      @@responses.last
    end

    def self.has_text?(phone, message)
      @@responses.any? do |r|
        r["to"] == phone && r["message"] == message
      end
    end

    def self.has_text_including?(phone, partial_message)
      @@responses.any? do |r|
        r["to"] == phone && r["message"].include?(partial_message)
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
