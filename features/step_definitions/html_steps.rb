Then 'I see a welcome page' do
  page.should have_content('text these commands')
end

Then 'I see no description of how to use the Web site' do
  page.should_not have_content('your phone number')
end
