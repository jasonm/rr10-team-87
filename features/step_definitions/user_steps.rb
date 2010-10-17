Given '"$phone_number" is a confirmed user' do |phone_number|
  Factory(:user, :phone_number => phone_number)
end

Then '"$phone_number" is confirmed' do |phone_number|
  user = User.find_by_phone_number!(phone_number)
  user.should be_confirmed
end

Then '"$phone_number" is unconfirmed' do |phone_number|
  user = User.find_by_phone_number!(phone_number)
  user.should_not be_confirmed
end

Then 'a user has a phone number of "$phone_number"' do |phone_number|
  User.find_by_phone_number(phone_number).should be,
    "could not find the user with the phone number #{phone_number}; was it normalized?"
end

Given 'the following two users are scheduled to date:' do |table|
  users = table.raw.map do |phone_number,|
    Factory(:user, :phone_number => phone_number)
  end
  Factory(:scheduled_meetup,
          :first_user => users.first,
          :second_user => users.second)
end

Then /^the "([^"]*)" user should be deleted$/ do |phone_number|
  User.find_by_phone_number(phone_number).should be_nil
end

Then /^"([^"]*)" should have only one proposed meetup$/ do |phone_number|
  User.find_by_phone_number(phone_number).founded_meetups.proposed.count.should == 1
end

Then /^"([^"]*)" should have no proposed meetups$/ do |phone_number|
  User.find_by_phone_number(phone_number).founded_meetups.proposed.count.should be_zero
end
