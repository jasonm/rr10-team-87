When /^jobs are processed$/ do
  QUEUE.run_jobs
end

When /^jobs are cleared/ do
  QUEUE.reset
end
