class User < ActiveRecord::Base
  attr_protected :secret_code, :phone_number

  # The magic of finding a match and making a date.
  # Produces either a scheduled or an unscheduled meetup.
  def schedule_date_in(location)
    Meetup.new
  end
end
