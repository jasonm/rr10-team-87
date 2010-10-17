Then 'I see a description of how to use the Web site' do
  page.should have_content('you want a date')
end

Then 'I see a welcome page' do
  page.should have_content('Congratulations, you are now an instalover!')
end

Then 'I see no description of how to use the Web site' do
  page.should_not have_content('your phone number')
end
