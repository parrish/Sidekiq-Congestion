require 'congestion'
require 'sidekiq'
require 'sidekiq/congestion/version'

module Sidekiq
  module Congestion
    ::Congestion.default_options[:track_rejected] = true
    ::Congestion.redis = ->{
      ::Sidekiq.redis{ |redis| redis }
    }
  end
end
