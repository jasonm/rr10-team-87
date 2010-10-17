class User < ActiveRecord::Base
  attr_protected :secret_code, :phone_number
  validates_presence_of :phone_number
  validate :secret_code_matches_or_nil
  validates_presence_of :name, :description, :looking_for_minimum_age, :looking_for_maximum_age,
    :on => :update
  validate :at_least_one_gender, :on => :update
  validate :at_least_one_desired_gender, :on => :update
  validates_presence_of :dob, :on => :update
  validate :phone_number_new, :on => :create

  before_validation :secret_code, :on => :create
  before_validation :normalize_phone_number
  after_create :deliver_secret_code
  after_save :deliver_confirmation_congratulations

  has_many :founded_meetups, :class_name => 'Meetup', :foreign_key => 'first_user_id'
  has_many :offers, :foreign_key => "offered_user_id"
  has_many :dflns

  attr_accessor :secret_code_confirmation

  def self.without_offers
    where('users.id NOT IN (SELECT offered_user_id FROM offers WHERE offers.state = "pending")')
  end

  def self.without_founded_meetups_in_progress
    where("users.id NOT IN (SELECT first_user_id FROM meetups WHERE meetups.state = 'proposed' OR meetups.state = 'unscheduled')")
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

  def unconfirmed?
    ! confirmed?
  end

  def age_in_years
    ((Date.today - dob).to_f / 365.0).floor
  end

  # The person this user has as a date right now
  def date
    Meetup.for(self).scheduled.newest.first.try(:for, self)
  end

  ### TODO: Can find yourself
  def matching
    finder = User.
      within_age_range(self.looking_for_minimum_age, self.looking_for_maximum_age).
      looking_for(self).
      without_offers.
      without_founded_meetups_in_progress

    finder = finder.men   if self.looking_for_male
    finder = finder.women if self.looking_for_female
    finder = finder.other if self.looking_for_other
    finder
  end

  def deliver_secret_code
    Message.deliver(self.phone_number,
      "Before you can become an instalover you must know this secret code: '#{self.secret_code}'. " +
      "Visit instalover.com to finish signing up.")
  end

  def latest_offer
    offers.pending.first
  end

  protected

  def normalize_phone_number
    normalized = self.phone_number.gsub(/[^0-9]/,'')
    self.phone_number = normalized.chars.first == '1' ? normalized : "1#{normalized}"
  end

  def phone_number_new
    user = User.find_by_phone_number(self.phone_number)
    if !user.nil?
      if user.confirmed?
        Message.deliver(user.phone_number,
                             "You are already a user - text 'new date' to start getting dates and 'safeword' to quit")
      else
        user.deliver_secret_code
      end
      errors.add(:base, "That number has already been registered! We have retexted instructions.")
    end
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

  def secret_code_matches_or_nil
    return true if self.secret_code_confirmation.nil?

    if self.secret_code.try(:downcase) != self.secret_code_confirmation.try(:downcase)
      self.errors.add(:secret_code, "doesn't match")
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
      virgin
      lonely
      shaved)
    codes[rand(codes.length)]
  end

  def just_updated_for_the_first_time?
    we_have_updated            = self.updated_at     != self.created_at
    we_had_not_updated_before  = self.updated_at_was == self.created_at

    we_have_updated && we_had_not_updated_before
  end

  def deliver_confirmation_congratulations
    if just_updated_for_the_first_time?
      Message.deliver(self.phone_number,
        "Congrats, #{self.name}, you are now an instalover.  Text 'new date' to get a new date.")
    end
  end
end
