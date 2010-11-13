Given 'the day and time is "$datetime"' do |datetime|
  Timecop.return
  Timecop.freeze(DateTime.parse(datetime))
end

Given %r{it is (\d+) hours? later} do |h|
  Timecop.freeze(h.to_i.hours.from_now)
end

Given %r{it is (\d+) days? later} do |d|
  Timecop.freeze(d.to_i.days.from_now)
end
