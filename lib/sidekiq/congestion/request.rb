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
        !!options
      end

      def key
        @key ||= case options[:key]
        when Proc
          options[:key].call args
        when String, Symbol
          options[:key].to_s
        else
          worker.class.name
        end
      end

      def congestion
        @congestion ||= ::Congestion.request key, options
      end
    end
  end
end
