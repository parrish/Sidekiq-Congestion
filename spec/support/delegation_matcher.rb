require 'spec_helper'

RSpec::Matchers.define :delegate do |method_name, opts|
  match do |source|
    to = opts[:to]
    target = source.send to
    allow(target).to receive method_name
    source.send method_name
    expect(target).to have_received method_name
  end

  failure_message do |source|
    "Expected #{ source } to delegate #{ method_name } to #{ to }, but it did not"
  end

  failure_message_when_negated do |source|
    "Expected #{ source } to not delegate #{ method_name } to #{ to }, but it did"
  end
end
