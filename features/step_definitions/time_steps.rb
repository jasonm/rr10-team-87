Given 'the day and time is "$datetime"' do |datetime|
  Timecop.freeze(DateTime.parse(datetime))
end
