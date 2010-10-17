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

