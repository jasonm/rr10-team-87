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
  r = Net::HTTP.post_form(URI.parse("http://www.example.com/messages"),
    {:session => {
      :id => '1',
      :accountId => '2',
      :timestamp => Time.now.iso8601,
      :userType => 'NONE',
      :initialText => nil,
      :callId => '3',
      :parameters => params
    }})
  p r
  FakeTropo::Response.add!(@response)
  ''
end

ShamRack.at('api.tropo.com').rackup do
  run Sinatra::Application
end
