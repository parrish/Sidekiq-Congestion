require 'forwardable'

module Sidekiq
  module Congestion
    class Request
      extend Forwardable
      attr_accessor :worker, :args, :options

      def_delegators :congestion,
        :allowed?, :backoff, :first_request, :last_request,
        :rejected?, :too_frequent?, :too_many?, :total_requests

      def initialize(worker, job, queue)
        self.worker = worker
        self.args = job['args']
        opts = worker.sidekiq_options_hash || { }
        self.options = opts['congestion']
      end

      def enabled?
        !!options && _enabled?
      end

      def reschedule?
        rejection_method == :reschedule
      end

      def reschedule!
        worker.class.perform_in backoff, *args
      end

      def key
        @key ||= case options[:key]
        when Proc
          options[:key].call *args
        when String, Symbol
          options[:key].to_s
        else
          worker.class.name
        end
      end

      def congestion
        @congestion ||= ::Congestion.request key, options
      end

      protected

      def _enabled?
        case options[:enabled]
        when Proc
          options[:enabled].call *args
        when nil
          true
        else
          !!options[:enabled]
        end
      end

      def rejection_method
        options.fetch(:reject_with, :reschedule).to_sym
      end
    end
  end
end
