class User < ActiveRecord::Base
  attr_protected :secret_code, :phone_number

  has_many :founded_meetups, :class => 'Meetup', :foreign_key => 'first_user_id'

  # The magic of finding a match and making a date.
  # Produces either a scheduled or an unscheduled meetup.
  def schedule_date_in(location)
    meetup_finder_near(location).first || founded_meetups.build(:location => location)
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
end
