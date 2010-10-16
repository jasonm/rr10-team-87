class Meetup < ActiveRecord::Base
  belongs_to :first_user, :class_name => 'User'
  belongs_to :second_user, :class_name => 'User'

  validates_presence_of :first_user_id

  # All the unscheduled dates.
  def self.unscheduled
    where('second_user_id IS NOT NULL AND location IS NOT NULL')
  end

  # All dates near a place.
  ### TODO: Geocoding stuff.
  def self.near(place)
    where('location = ?', place)
  end

  def self.within_age_range(min, max)
    joins('JOIN users ON users.id = first_user_id').
      where('NOW() - users.dob >= ? AND NOW() - users.dob <= max', min, max)
  end

  def self.looking_for(user)
    joins('JOIN users ON users.id = first_user_id').
      where('(users.looking_for_male = ? OR users.looking_for_female = ? OR users.looking_for_other = ?) AND users.looking_for_minimum_age >= ? AND users.looking_for_maximum_age <= ?',
            user.male, user.female, user.other, user.age_in_years, user.age_in_years)
  end

  def self.men
    joins('JOIN users ON users.id = first_user_id').where('users.male')
  end

  def self.women
    joins('JOIN users ON users.id = first_user_id').where('users.female')
  end

  def self.other
    joins('JOIN users ON users.id = first_user_id').where('users.other')
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

  # True if the date has two people and a meeting spot.
  def scheduled?
    second_user_id.present? && location.present?
  end

  def unscheduled?
    ! scheduled?
  end
end
