# frozen_string_literal: true

require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe StripeApiProcessorWorker do
  let(:event) { create(:stripe_api_event) }
  before do
    Sidekiq::Testing.fake!
    Sidekiq::Worker.clear_all
    allow(Stripe::Event).to receive(:retrieve)
  end

  after do
    Sidekiq::Worker.drain_all
  end

  subject { StripeApiProcessorWorker }

  it 'StripeApiProcessor job is processed added to the job queue' do
    expect { subject.perform_async('evt_123test123', '2019-05-16') }.to change(subject.jobs, :size).by(1)
  end

  it 'creates a StripeApiEvent record' do
    expect(StripeApiEvent).to receive(:create!)

    subject.perform_async('evt_123test123', '2019-05-16')
  end

  it 'rescues from invalid records and logs the output' do
    allow(StripeApiEvent).to receive(:create!).and_raise(ActiveRecord::RecordInvalid)
    expect(Rails.logger).to receive(:error)

    subject.perform_async('evt_123test123', '2019-05-16')
  end
end
