require 'spec_helper'

describe Sidekiq::Congestion::Limiter do
  include_context 'sidekiq helper'
  let(:limiter){ Sidekiq::Congestion::Limiter.new }
  let(:worker){ LimitedWorker }

  describe '#call' do
    before(:each){ worker.perform_async }

    it 'should initialize a request' do
      expect(Sidekiq::Congestion::Request).to receive(:new)
        .with(worker, a_kind_of(Hash), 'default').and_call_original
      process_job
    end

    context 'when the worker is limited' do
      let(:worker){ LimitedWorker }

      it 'should handle the request' do
        expect_any_instance_of(limiter.class).to receive :handle
        process_job
      end
    end

    context 'when the worker is not limited' do
      let(:worker){ UnlimitedWorker }

      it 'should not handle the request' do
        expect_any_instance_of(limiter.class).to_not receive :handle
        process_job
      end
    end
  end

  describe '#handle' do
    let(:block){ ->{ } }
    before(:each) do
      allow(block).to receive :call
      limiter.handle request, block
    end

    context 'when the request is allowed' do
      subject{ block }
      let(:request){ double allowed?: true }
      it{ is_expected.to have_received :call }
    end

    context 'when the request is not allowed' do
      context 'and is rescheduled' do
        let(:request) do
          double allowed?: false, reschedule?: true, reschedule!: true
        end

        it 'should not yield' do
          expect(block).to_not have_received :call
        end

        it 'should reschedule the job' do
          expect(request).to have_received :reschedule!
        end
      end

      context 'and is cancelled' do
        let(:request) do
          double allowed?: false, reschedule?: false
        end

        it 'should not yield' do
          expect(block).to_not have_received :call
        end
      end
    end
  end
end
