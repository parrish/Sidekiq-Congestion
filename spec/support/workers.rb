Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add Sidekiq::Congestion::Limiter
  end
end

class LimitedWorker
  include Sidekiq::Worker

  sidekiq_options congestion: {
    interval: 60 * 60,  # one hour
    max_in_interval: 5, # 5 / hour
    min_delay: 5 * 60   # 5 minutes
  }

  def perform(*args)
  end
end

class UnlimitedWorker
  include Sidekiq::Worker

  def perform(*args)
  end
end

class ConditionalWorker
  include Sidekiq::Worker

  sidekiq_options congestion: { }

  def self.true_proc
    ->(*args){ true }
  end

  def self.false_proc
    ->(*args){ false }
  end

  def perform(*args)
  end
end