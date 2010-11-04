namespace :instalover do
  desc "Ping women for dates to poke the pot"
  task :ping_female_dates => :environment do
    User.women.each do |w|
      Message.handle_new_date(w)
    end
  end

  desc "Backfill events"
  task :backfill_events => :environment do
    [Meetup, Offer].each do |eventable_class|
      eventable_class.all.each do |eventable_instance|
        eventable_instance.send(:create_event)
      end
    end
  end
end
