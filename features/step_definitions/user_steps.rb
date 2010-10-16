Given /^"([^"]*)" is confirmed$/ do |phone_number|
  Factory :user, :phone_number => phone_number
end

