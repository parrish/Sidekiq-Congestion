require 'spec_helper'

describe Sidekiq::Congestion do
  it 'has a version number' do
    expect(Sidekiq::Congestion::VERSION).not_to be nil
  end
end
