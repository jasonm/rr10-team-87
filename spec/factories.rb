Factory.sequence :phone_number do |n|
  "617#{n}"
end

Factory.define :user do |u|
  u.phone_number    { Factory.next :phone_number }
  u.secret_code     { "supercode" }
  u.name            { "Jenny" }
end

Factory.define :date_suggestion do |ds|
  ds.text  { "Thoughtbot" }
end
