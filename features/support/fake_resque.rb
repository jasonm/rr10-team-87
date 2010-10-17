class FakeResque
  cattr_accessor :queue
  self.queue = []

  def self.enqueue(klass, *args)
    self.queue << [klass, args.to_json]
  end

  def self.run_jobs
    while !self.queue.empty?
      args = self.queue.pop
      klass, args = args.shift, args.shift
      klass.send(:perform, *JSON.parse(args))
    end
  end

  def self.reset
    self.queue = []
  end
end
