module SmsHelpers
  def secret_code
    response = FakeTropo::Response.last
    response =~ %r{code: ([0-9a-zA-Z]+)}
    $1
  end
end

World(SmsHelpers)
