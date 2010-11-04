class Event < ActiveRecord::Base
  def date
    created_at.to_s(:long_date)
  end

  def time
    created_at.to_s(:short_time)
  end

  def self.recent
    order("created_at desc")
  end
end
