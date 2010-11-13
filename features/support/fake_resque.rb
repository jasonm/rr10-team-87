class FakeResque
  cattr_accessor :queue
  cattr_accessor :delayed_queue
  self.queue = []
  self.delayed_queue = []

  def self.enqueue(klass, *args)
    self.queue << [klass, args.to_json]
  end

  def self.enqueue_at(timestamp, klass, *args)
    self.delayed_queue << [timestamp, klass, args.to_json]
  end

  def self.run_jobs
    while !self.queue.empty?
      args = self.queue.pop
      klass, args = args.shift, args.shift
      klass.send(:perform, *JSON.parse(args))
    end
  end

  def self.run_timed_jobs(future_time)
    self.delayed_queue.each do |timestamp, klass, args|
      time_diff = future_time - timestamp
      if  time_diff < 1 && time_diff >= 0
        klass.send(:perform, *JSON.parse(args))
      end
    end
  end

  def self.reset
    self.queue = []
    self.delayed_queue = []
  end
end
