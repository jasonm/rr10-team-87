class DateSuggestion < ActiveRecord::Base

  def self.next_place
    suggestion = self.order('last_suggested_at ASC').first
    suggestion.update_attributes({:last_suggested_at => Time.now})
    suggestion
  end

  def self.next_place_and_time
    place = next_place
    time = 1.hour.from_now.strftime("%I:%M%p")
    "#{place.text} at #{time}"
  end
end
