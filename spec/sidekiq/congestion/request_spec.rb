require 'spec_helper'

RSpec.describe Sidekiq::Congestion::Request do
  let(:job){ { 'args' => ['foo', 'bar'] } }
  let(:worker){ LimitedWorker }
  let(:request){ described_class.new worker.new, job, 'default' }
  subject{ request }

  describe '#enabled?' do
    context 'when enabled and not set' do
      let(:worker){ LimitedWorker }
      it{ is_expected.to be_enabled }
    end

    context 'when disabled and not set' do
      let(:worker){ UnlimitedWorker }
      it{ is_expected.to_not be_enabled }
    end

    context 'with true' do
      let(:worker){ ConditionalWorker }
      before(:each){ request.options[:enabled] = true }
      it{ is_expected.to be_enabled }
    end

    context 'with false' do
      let(:worker){ ConditionalWorker }
      before(:each){ request.options[:enabled] = false }
      it{ is_expected.to_not be_enabled }
    end

    context 'with a proc' do
      let(:worker){ ConditionalWorker }

      context 'returning false' do
        before(:each){ request.options[:enabled] = worker.false_proc }
        it{ is_expected.to_not be_enabled }
      end

      context 'returning true' do
        before(:each){ request.options[:enabled] = worker.true_proc }
        it{ is_expected.to be_enabled }
      end
    end
  end

  describe '#reschedule?' do
    context 'when enabled' do
      before(:each){ request.options[:reject_with] = :reschedule }
      it{ is_expected.to be_reschedule }
    end

    context 'when disabled' do
      before(:each){ request.options[:reject_with] = :cancel }
      it{ is_expected.to_not be_reschedule }
    end
  end

  describe '#options' do
    subject{ request.options }

    context 'when the options exist' do
      let(:worker){ LimitedWorker }
      it{ is_expected.to have_key :interval }
    end

    context 'when the options do not exist' do
      let(:worker){ UnlimitedWorker }
      it{ is_expected.to be_nil }
    end
  end

  describe '#key' do
    let(:worker){ LimitedWorker }
    subject{ request.key }

    context 'with no key specified' do
      before(:each){ request.options[:key] = nil }
      it{ is_expected.to eql 'LimitedWorker' }
    end

    context 'with a string key' do
      before(:each){ request.options[:key] = 'something' }
      it{ is_expected.to eql 'something' }
    end

    context 'with a symbol key' do
      before(:each){ request.options[:key] = :something }
      it{ is_expected.to eql 'something' }
    end

    context 'with a proc key' do
      let(:proc_key){ ->(*args){ "something_#{ args.join('-') }" } }
      before(:each){ request.options[:key] = proc_key }
      it{ is_expected.to eql 'something_foo-bar' }
    end
  end

  describe '#congestion' do
    it 'should initialize a Congestion request' do
      expect(::Congestion).to receive(:request).with request.key, request.options
      request.congestion
    end

    it 'should memoize the result' do
      expect(::Congestion).to receive(:request).once.and_call_original
      2.times{ request.congestion }
    end
  end

  describe '#reschedule!' do
    it 'should schedule the job' do
      allow(request).to receive(:backoff).and_return 123
      expect(worker).to receive(:perform_in).with 123, *job['args']
      request.reschedule!
    end
  end

  it{ is_expected.to delegate :allowed?,       to: :congestion }
  it{ is_expected.to delegate :backoff,        to: :congestion }
  it{ is_expected.to delegate :first_request,  to: :congestion }
  it{ is_expected.to delegate :last_request,   to: :congestion }
  it{ is_expected.to delegate :rejected?,      to: :congestion }
  it{ is_expected.to delegate :too_frequent?,  to: :congestion }
  it{ is_expected.to delegate :too_many?,      to: :congestion }
  it{ is_expected.to delegate :total_requests, to: :congestion }
end
