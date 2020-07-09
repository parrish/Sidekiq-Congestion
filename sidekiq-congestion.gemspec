# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'sidekiq/congestion/version'

Gem::Specification.new do |spec|
  spec.name          = 'sidekiq-congestion'
  spec.version       = Sidekiq::Congestion::VERSION
  spec.authors       = ['Michael Parrish']
  spec.email         = ['michael@zooniverse.org']

  spec.summary       = %q{Redis rate limiter Sidekiq middleware}
  spec.description   = %q{Sidekiq middleware rate limiter that provides both time-based limits and quantity-based limits}
  spec.homepage      = 'https://github.com/parrish/sidekiq-congestion'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency     'congestion', '~> 0.1'
  spec.add_runtime_dependency     'sidekiq', '>= 3.0'
  spec.add_development_dependency 'bundler', '>= 1.5'
  spec.add_development_dependency 'rake', '>= 1.13.3'
  spec.add_development_dependency 'rspec', '~> 3.2'
  spec.add_development_dependency 'rspec-its', '~> 1.2'
  spec.add_development_dependency 'guard-rspec', '~> 4.5'
  spec.add_development_dependency 'timecop', '~> 0.7'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'codeclimate-test-reporter'
end
