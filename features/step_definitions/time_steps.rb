Given 'the day and time is "$datetime"' do |datetime|
  Timecop.freeze(DateTime.parse(datetime))
end

Given %r{it is (\d+) hours? later} do |h|
  h = h.to_i
  Timecop.freeze(h.hours.from_now)
end
