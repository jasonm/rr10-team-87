class User < ActiveRecord::Base
  attr_protected :secret_code, :phone_number
  validates_presence_of :phone_number
  validates_confirmation_of :secret_code, :allow_nil => true
  validates_presence_of :name, :description, :looking_for_minimum_age, :looking_for_maximum_age,
    :on => :update
  validate :at_least_one_gender, :on => :update
  validate :at_least_one_desired_gender, :on => :update
  validates_presence_of :dob, :on => :update

  before_create :normalize_phone_number
  after_create :deliver_secret_code

  has_many :founded_meetups, :class_name => 'Meetup', :foreign_key => 'first_user_id'
  has_many :offers, :foreign_key => "offered_user_id"

  # The magic of finding a match and making a date.
  # Produces either a scheduled or an unscheduled meetup.
  #def schedule_date_in(location)
  #  meetup_finder_near(location).first || founded_meetups.build(:location => location)
  #end

  # The secret code that the user uses to prove that they have that phone
  # number.
  def secret_code
    read_attribute(:secret_code) ||
      write_attribute(:secret_code, generate_secret_code)
  end

  # A user is confirmed if they have a name
  def confirmed?
    self.name.present?
  end

  def age_in_years
    ((Date.today - dob).to_f / 365.0).floor
  end

  # The person this user has as a date right now
  def date
    Meetup.for(self).newest.first.try(:for, self)
  end


  def matching
    finder = User.
      within_age_range(self.looking_for_minimum_age, self.looking_for_maximum_age).
      looking_for(self).
      without_offers

    finder = finder.men   if self.looking_for_male
    finder = finder.women if self.looking_for_female
    finder = finder.other if self.looking_for_other
    finder
  end

  def self.without_offers
    where('users.id not in (select offered_user_id from offers)')
  end

  def self.within_age_range(min, max)
    where('DATEDIFF(:today, dob) >= :min * 365 AND DATEDIFF(:today,  dob) <= :max * 365', { :today => Date.today, :min => min, :max => max })
  end

  def self.looking_for(user)
    where('(users.looking_for_male = ? OR users.looking_for_female = ? OR users.looking_for_other = ?) AND ? >= users.looking_for_minimum_age AND ? <= users.looking_for_maximum_age',
          user.male, user.female, user.other, user.age_in_years, user.age_in_years)
  end

  def self.men
    where('users.male')
  end

  def self.women
    where('users.female')
  end

  def self.other
    where('users.other')
  end


  protected

  #def meetup_finder_near(location)
  #  finder = Meetup.unscheduled.
  #    within_age_range(self.looking_for_minimum_age, self.looking_for_maximum_age).
  #    looking_for(self)
  #  finder = finder.men   if self.looking_for_male
  #  finder = finder.women if self.looking_for_female
  #  finder = finder.other if self.looking_for_other
  #  finder
  #end

  def deliver_secret_code
    Message.deliver(self.phone_number,
                    "Before you can become an instalover you must know this secret code: #{self.secret_code}")
  end

  def normalize_phone_number
    normalized = self.phone_number.gsub(/[^0-9]/,'')
    self.phone_number = normalized.chars.first == '1' ? normalized : "1#{normalized}"
  end

  def at_least_one_gender
    unless (male? || female? || other?)
      errors.add(:base, "must select at least one gender")
    end
  end

  def at_least_one_desired_gender
    unless (looking_for_male? || looking_for_female? || looking_for_other?)
      errors.add(:base, "must look for at least one gender")
    end
  end

  def generate_secret_code
    codes = %w(
      bunny
      love
      date
      heart
      marry
      divorce
      regret
      tiny
      huge
      cry
      nerd
      geek
      cheat
      friend
      hurt
      lemon
      small
      tissue
      lotion
      booze
      mucus
      sleep
      breakfast
      morning
      shaved)
    codes[rand(codes.length)]
  end
end
