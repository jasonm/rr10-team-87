class User < ActiveRecord::Base
  attr_protected :secret_code, :phone_number
  validates_presence_of :phone_number

  after_create :deliver_secret_code

  has_many :founded_meetups, :class_name => 'Meetup', :foreign_key => 'first_user_id'

  # The magic of finding a match and making a date.
  # Produces either a scheduled or an unscheduled meetup.
  def schedule_date_in(location)
    meetup_finder_near(location).first || founded_meetups.build(:location => location)
  end

  def secret_code
    read_attribute(:secret_code) ||
      write_attribute(:secret_code, generate_secret_code)
  end

  protected

  def meetup_finder_near(location)
    finder = Meetup.unscheduled.
      near(location).
      within_age_range(self.looking_for_minimum_age, self.looking_for_maximum_age).
      looking_for(self)
    finder = finder.men   if self.looking_for_male
    finder = finder.women if self.looking_for_female
    finder = finder.other if self.looking_for_other
    finder
  end

  def deliver_secret_code
    Message.deliver(self.phone_number,
                    "Before you can become an Instalover you must know this secret code: #{self.secret_code}")
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
