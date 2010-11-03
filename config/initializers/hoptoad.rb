require 'resque/failure/hoptoad'

[HoptoadNotifier, Resque::Failure::Hoptoad].each do |notifier|
  notifier.configure do |config|
    config.api_key = 'f12b4bfa6c4e2ea65f55e8f871ccf1f3'
  end
end
