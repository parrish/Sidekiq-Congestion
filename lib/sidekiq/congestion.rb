require 'congestion'
require 'sidekiq'
require 'sidekiq/congestion/version'

module Sidekiq
  module Congestion
    require 'sidekiq/congestion/request'
    require 'sidekiq/congestion/limiter'
    ::Congestion.default_options[:track_rejected] = true
    ::Congestion.redis = ->{
      ::Sidekiq.redis{ |redis| redis }
    }
  end
end
