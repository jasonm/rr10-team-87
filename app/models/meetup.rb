class Meetup < ActiveRecord::Base
  # In a scheduled date produce the user that is opposite the one passed in.
  # In an unscheduled date produce nil.
  def for(user)
    nil
  end

  # True if the date has two people and a meeting spot.
  def scheduled?
    false
  end
end
