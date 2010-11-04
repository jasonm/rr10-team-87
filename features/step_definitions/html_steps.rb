Then 'I see a description of how to use the Web site' do
  page.should have_content('you want a date')
end

Then 'I see a welcome page' do
  page.should have_content('text these commands')
end

Then 'I see no description of how to use the Web site' do
  page.should_not have_content('your phone number')
end

Then %{I should see the following table:} do |table|
  table.diff!(tableish('table', "th,td"))
end
