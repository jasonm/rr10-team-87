class Meetup < ActiveRecord::Base
  belongs_to :first_user, :class_name => 'User'
  belongs_to :second_user, :class_name => 'User'
  has_many :offers
  has_many :dflns

  after_save :schedule_jobs

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

  # All meetups for the given user
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

  def unschedule!
    self.state = "unscheduled"
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

  private

  def schedule_jobs
    if state_was == "unscheduled" && state == "scheduled"
      morning_after = 1.day.from_now.beginning_of_day + 10.hours
      QUEUE.enqueue_at(morning_after, MorningAfterCheckerUpper, { :meetup_id => self.id })
    end
  end
end
