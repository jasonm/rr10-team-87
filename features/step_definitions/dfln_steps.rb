Then /^there should be a DFLN from "([^"]*)" about their most recent meetup that says "([^"]*)"$/ do |user_phone, dfln_text|
  user = User.find_by_phone_number(user_phone)
  user.should be

  Dfln.find_by_user_id_and_text(user, dfln_text).should be
end
