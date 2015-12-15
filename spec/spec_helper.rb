require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'pry'
require 'rspec/its'
require 'timecop'

require 'sidekiq'
require 'celluloid' if Sidekiq::VERSION < '4'

require 'sidekiq/processor'
require 'sidekiq/fetch'
require 'sidekiq/congestion'

Celluloid.logger = nil if Sidekiq::VERSION < '4'
Sidekiq.logger = nil
Sidekiq.options[:queues] << 'default'

module Sidekiq
  def self.server?
    true
  end
end

Dir['./spec/support/**/*.rb'].sort.each{ |f| require f }

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'
  config.before(:each) do
    Sidekiq.redis{ |redis| redis.flushdb }
  end
end
