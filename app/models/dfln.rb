class Dfln < ActiveRecord::Base
  belongs_to :user
  belongs_to :meetup

  def self.unwritten
    where('text is null')
  end

  def about_whom
    if user == meetup.first_user
      meetup.second_user
    else
      meetup.first_user
    end
  end
end
