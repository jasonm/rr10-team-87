namespace :instalover do
  desc "Ping women for dates to poke the pot"
  task :ping_female_dates => :environment do
    User.women.each do |w|
      Message.handle_new_date(w)
    end
  end
end
