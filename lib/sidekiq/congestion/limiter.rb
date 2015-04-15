module Sidekiq
  module Congestion
    class Limiter
      def call(worker, job, queue, &block)
        request = Sidekiq::Congestion::Request.new worker, job, queue
        request.enabled? ? handle(request, block) : yield
      end

      def handle(request, block)
        if request.allowed?
          block.call
        elsif request.reschedule?
          request.reschedule!
        else
          # cancel request
        end
      end
    end
  end
end
