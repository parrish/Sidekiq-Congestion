require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'pry'
require 'rspec/its'
require 'sidekiq/testing'
require 'timecop'
require 'sidekiq/congestion'
Dir['./spec/support/**/*.rb'].sort.each{ |f| require f }

Sidekiq::Testing.inline!

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'

  config.before(:each) do
    Sidekiq::Worker.clear_all
  end
end
