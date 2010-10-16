Then 'I see a description of how to use the Web site' do
  page.should have_content('how to use')
end

Then 'I see no description of how to use the Web site' do
  page.should_not have_content('how to use')
end
