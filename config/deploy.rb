require 'bundler/capistrano'

set :application, "instalover"
set :repository,  "git@github.com:railsrumble/rr10-team-87.git"
set :user, 'deploy'

set :scm, :git

role :web, "173.255.195.4"
role :app, "173.255.195.4"
role :db,  "173.255.195.4", :primary => true
role :db,  "173.255.195.4"

set :deploy_to, "/srv/www/li205-4.members.linode.com"

# Passenger
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end
