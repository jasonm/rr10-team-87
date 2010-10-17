module SmsHelpers
  def secret_code
    QUEUE.run_jobs
    response = FakeTropo::Response.last
    response.should_not be_nil,
      "expected Tropo to ping us. Perhaps you meant to call Message.deliver."
    response['message'] =~ %r{code: '([0-9a-zA-Z]+)'}
    $1
  end
end

World(SmsHelpers)
