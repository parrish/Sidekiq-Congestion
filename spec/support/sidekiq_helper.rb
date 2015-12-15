require 'spec_helper'

RSpec.shared_context 'sidekiq helper' do
  let(:manager){ double real_thread: Thread.current, processor_done: true }
  let(:boss){ double async: manager, options: { queues: ['default'] } }
  let(:processor){ Sidekiq::Processor.new boss }

  def process_job
    work = Sidekiq::BasicFetch.new(Sidekiq.options).retrieve_work
    processor.send(:process, work) if work
  end

  around(:each) do |example|
    Celluloid.boot if Sidekiq::VERSION < '4'
    example.run
    Celluloid.shutdown if Sidekiq::VERSION < '4'
  end
end
