When /^jobs are processed$/ do
  QUEUE.run_jobs
end

When /^jobs are cleared/ do
  QUEUE.reset
end

When /^jobs in (\d+) minutes from now are procedsed$/ do |min|
  Timecop.freeze(Time.now + min.to_i.minutes)
  QUEUE.run_timed_jobs(Time.now)
end

When 'jobs tomorrow at 10am are processed' do
  morning_after = 1.day.from_now.beginning_of_day + 10.hours
  Timecop.freeze(morning_after)
  QUEUE.run_timed_jobs(Time.now)
end
