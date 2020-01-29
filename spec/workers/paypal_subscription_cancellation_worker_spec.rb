# frozen_string_literal: true

require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe PaypalSubscriptionCancellationWorker do
  let(:subscription) { build_stubbed(:subscription) }

  before do
    Sidekiq::Testing.fake!
    Sidekiq::Worker.clear_all
    allow(Subscription).to receive(:find).and_return(subscription)
  end

  after do
    Sidekiq::Worker.drain_all
  end

  subject { PaypalSubscriptionCancellationWorker }

  it 'processes the job in the medium queue' do
    expect { subject.perform_async(rand(10)) }.to change(subject.jobs, :size).by(1)
  end

  it 'does not call #cancel_billing_agreement_immediately if the subscription is not pending_cancellation' do
    expect_any_instance_of(PaypalSubscriptionsService).not_to receive(:cancel_billing_agreement_immediately)

    subject.perform_async(subscription.id)
  end

  it 'calls #cancel_billing_agreement_immediately if the subscription is pending_cancellation' do
    expect_any_instance_of(PaypalSubscriptionsService).to receive(:cancel_billing_agreement_immediately)
    subscription.state = 'pending_cancellation'

    subject.perform_async(subscription.id)
  end
end
