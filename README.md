# Sidekiq::Congestion

[![Build Status](https://travis-ci.org/parrish/Sidekiq-Congestion.svg?branch=master)](https://travis-ci.org/parrish/Sidekiq-Congestion)
[![Test Coverage](https://codeclimate.com/github/parrish/Sidekiq-Congestion/badges/coverage.svg)](https://codeclimate.com/github/parrish/Sidekiq-Congestion)
[![Code Climate](https://codeclimate.com/github/parrish/Sidekiq-Congestion/badges/gpa.svg)](https://codeclimate.com/github/parrish/Sidekiq-Congestion)
[![Gem Version](https://badge.fury.io/rb/sidekiq-congestion.svg)](http://badge.fury.io/rb/sidekiq-congestion)

Sidekiq middleware for [Congestion](https://github.com/parrish/Congestion)

Provides rate limiting for Sidekiq workers.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'sidekiq-congestion'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sidekiq-congestion

## Usage

[Documentation of Congestion configuration can be found here](https://github.com/parrish/Congestion#user-content-configuration)

However, `Sidekiq::Congestion` disables rejection tracking by default.

Rejection tracking would cause attempted calls to your workers (even if they don't trigger a run) to count towards the worker limits -- which is probably undesirable.  If your worker is high throughput, you may want to enable it just so the request tracking is [atomic](http://en.wikipedia.org/wiki/Linearizability).

In an initializer:

```ruby
# Set whatever default options you'd like
# Congestion.default_options[:track_rejected] = false

Sidekiq.configure_server do |config|
  config.server_middleware do |chain|
    chain.add Sidekiq::Congestion::Limiter
  end
end
```

In a worker:

```ruby
class YourWorker
  include Sidekiq::Worker

  # Allow 5 calls/hour, with at least 5 minutes between calls
  # When the request is not allowed, it is rescheduled
  sidekiq_options congestion: {
    interval: 1.hour,
    max_in_interval: 5,
    min_delay: 5.minutes,
    reject_with: :reschedule # (or :cancel)
  }
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To run the specs, run `bundle exec rake`.

## Contributing

1. Fork it ( https://github.com/parrish/sidekiq-congestion/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
