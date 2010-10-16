Given /^the day and time is "([^"]*)"$/ do |datetime|
  Timecop.freeze(DateTime.parse(datetime))
end


