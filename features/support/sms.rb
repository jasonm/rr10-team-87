module SmsHelpers
  def secret_code
    QUEUE.run_jobs
    response = FakeTropo::Response.all.reverse.detect do |response|
      response['message'] =~ %r{code: '([0-9a-zA-Z]+)'}
    end

    code = $1
    code.should_not be_nil, "expected Tropo to ping us. Perhaps you meant to call Message.deliver."
    code
  end
end

World(SmsHelpers)
