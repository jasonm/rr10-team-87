Given '"$phone_number" is a confirmed user' do |phone_number|
  Factory(:user, :phone_number => phone_number)
end

Then '"$phone_number" is confirmed' do |phone_number|
  user = User.find_by_phone_number(phone_number)
  user.should be_confirmed
end

Then '"$phone_number" is unconfirmed' do |phone_number|
  user = User.find_by_phone_number(phone_number)
  user.should_not be_confirmed
end
