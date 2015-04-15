require 'spec_helper'

RSpec.shared_context 'sidekiq helper' do
  let(:manager){ double real_thread: Thread.current, processor_done: true }
  let(:boss){ double async: manager }
  let(:processor){ Sidekiq::Processor.new boss }

  def process_job
    work = Sidekiq::BasicFetch.new(Sidekiq.options).retrieve_work
    processor.process(work) if work
  end

  around(:each) do |example|
    Celluloid.boot
    example.run
    Celluloid.shutdown
  end
end
