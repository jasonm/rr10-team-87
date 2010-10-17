class Dfln < ActiveRecord::Base
  belongs_to :user

  def self.unwritten
    where('text is null')
  end
end
