Then 'I get a text with my secret code' do
  QUEUE.run_jobs
  secret_code.should be, "found no secret code"
end

When /^"([^"]*)" texts instalover with "([^"]*)"$/ do |user_phone, message|
  Capybara.current_session.driver.process :post, '/messages', { :session => { :initialText => message, :from => { :id => user_phone} } }
  QUEUE.run_jobs
end

Then /^"([^"]*)" should get a text "([^"]*)"$/ do |user_phone, message|
  QUEUE.run_jobs
  FakeTropo::Response.should have_text(user_phone, message)
end

Then /^"([^"]*)" should get a text whose message includes "([^"]*)"$/ do |user_phone, message|
  QUEUE.run_jobs
  FakeTropo::Response.should have_text_including(user_phone, message)
end

Then /^"([^"]*)" should not get a text whose message includes "([^"]*)"$/ do |user_phone, message|
  QUEUE.run_jobs
  FakeTropo::Response.should_not have_text_including(user_phone, message)
end

When 'I clear the text message history' do
  QUEUE.run_jobs
  FakeTropo::Response.clear_all
end
