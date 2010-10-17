# This file is used by Rack-based servers to start the application.


require ::File.expand_path('../config/environment',  __FILE__)

require 'resque_scheduler' # include the resque_scheduler (this makes the tabs show up)
require 'resque/server'

run Rack::URLMap.new({
  "/"                    => Instalover::Application,
  "/secretsecret/resque" => Resque::Server.new
})
