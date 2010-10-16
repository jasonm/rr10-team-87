Then 'I get a text with my secret code' do
  secret_code.should be, "found no secret code"
end

When /^"([^"]*)" texts instalover with "([^"]*)"$/ do |user_phone, message|
  user = User.find_by_phone_number(user_phone)
  Capybara.current_session.driver.process :post, '/messages', { :session => { :initialText => message } }
end

Then /^"([^"]*)" should get a text "([^"]*)"$/ do |user_phone, message|
  FakeTropo::Response.should have_text(user_phone, message)
end


