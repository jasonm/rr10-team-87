Then /^"([^"]*)" should get matched with:$/ do |user_name, table_of_match_names|
  list_of_match_names = table_of_match_names.raw

  user = User.find_by_name!(user_name)
  matches = list_of_match_names.map { |match_name| User.find_by_name!(match_name) }

  messages = FakeTropo::Response.all
  messages.size.should == matches.size

  matches.each do |match|
    matching_message = messages.detect do |message|
      message["to"] == match.phone_number &&
        message["message"].include?("Should we find you a date") 
    end

    matching_message.should be
  end
end
