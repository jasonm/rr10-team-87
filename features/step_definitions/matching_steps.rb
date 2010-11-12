Then /^"([^"]*)" should get matched with:$/ do |user_name, table_of_match_names|
  list_of_match_names = table_of_match_names.raw

  user = User.find_by_name!(user_name)
  expected_matches = list_of_match_names.map { |match_name| User.find_by_name!(match_name) }
  meetup = Meetup.create(:first_user => user, :state => 'proposed')

  user.matching_for_meetup(meetup).map(&:phone_number).should =~ expected_matches.map(&:phone_number)

  meetup.destroy
end
