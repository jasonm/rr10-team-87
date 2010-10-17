class Meetup < ActiveRecord::Base
  belongs_to :first_user, :class_name => 'User'
  belongs_to :second_user, :class_name => 'User'
  has_many :offers

  validates_presence_of :first_user_id

  def self.newest
    order('created_at DESC')
  end

  # All the unscheduled dates.
  def self.unscheduled
    where('state = "unscheduled"')
  end

  # All the scheduled dates.
  def self.scheduled
    where('state = "scheduled"')
  end

  def self.proposed
    where('state = "proposed"')
  end

  def self.for(user)
    where('meetups.first_user_id = :id OR meetups.second_user_id = :id', :id => user.id)
  end

  # In a scheduled date produce the user that is opposite the one passed in.
  # In an unscheduled date produce nil.
  def for(user)
    if scheduled?
      if first_user_id == user.id
        second_user
      elsif second_user_id == user.id
        first_user
      end
    end
  end

  def make_unscheduled
    state = "unscheduled"
    self.save!
  end

  # True if the date has two people and a meeting spot.
  def scheduled?
    state == "scheduled"
  end

  def unscheduled?
    state == "unscheduled"
  end

  def proposed?
    state == "proposed"
  end
end
