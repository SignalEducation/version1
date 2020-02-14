# frozen_string_literal: true

require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe SubscriptionCancellationWorker do
  let(:subscription) { build_stubbed(:subscription) }

  before do
    Sidekiq::Testing.fake!
    Sidekiq::Worker.clear_all
    allow(Subscription).to receive(:find).and_return(subscription)
    allow_any_instance_of(Subscription).to receive(:cancel!).and_return(true)
  end

  after do
    Sidekiq::Worker.drain_all
  end

  subject { SubscriptionCancellationWorker }

  it 'Event Importer job is processed in importers queue.' do
    expect { subject.perform_async(subscription.id) }.to change(subject.jobs, :size).by(1)
  end
end
