When 'it is outside of the dating hours' do
  Timecop.freeze(Time.parse("11:00am edt"))
end

Then /^there should be a meetup founded by "([^"]*)" that is "([^"]*)"$/ do |founder_phone, meetup_state|
  user = User.find_by_phone_number(founder_phone)
  user.founded_meetups.detect { |meetup| meetup.state == meetup_state }.should be
end

