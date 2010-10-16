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
  end
end

get '/1.0/sessions' do
  FakeTropo::Response.add!(params)
  '<success>true</success>'
end

ShamRack.at('api.tropo.com').rackup do
  run Sinatra::Application
end
