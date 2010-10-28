Factory.sequence :phone_number do |n|
  "617#{n}"
end

Factory.define :user do |u|
  u.phone_number    { Factory.next :phone_number }
  u.secret_code     { "supercode" }
  u.name            { "Jenny" }
  u.description     { "great personality" }
end

Factory.define :young_person, :parent => :user do |u|
  u.dob { 21.years.ago }
  u.looking_for_minimum_age { 20 }
  u.looking_for_maximum_age { 22 }
end

Factory.define :date_suggestion do |ds|
  ds.text  { "Thoughtbot" }
end

Factory.define :scheduled_meetup, :class => Meetup do |meetup_factory|
  meetup_factory.association :first_user, :factory => :user
  meetup_factory.association :second_user, :factory => :user
  meetup_factory.state 'scheduled'
end
