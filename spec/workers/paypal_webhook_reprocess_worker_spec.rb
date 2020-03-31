# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PaypalWebhookReprocessWorker do
  let(:webhook) { build_stubbed(:paypal_webhook) }

  before do
    Sidekiq::Testing.fake!
    Sidekiq::Worker.clear_all
    allow(PaypalWebhook).to receive(:find).and_return(webhook)
  end

  after do
    Sidekiq::Worker.drain_all
  end

  subject { PaypalWebhookReprocessWorker }

  it 'processes the job in the medium queue' do
    allow_any_instance_of(PaypalWebhookService).to receive(:reprocess_webhook)
    expect { subject.perform_async(webhook) }.to change(subject.jobs, :size).by(1)

    subject.perform_async(webhook.id)
  end

  it 'calls #reprocess_webhook on the PaypalWebhookService' do
    expect_any_instance_of(PaypalWebhookService).to receive(:reprocess_webhook).with(webhook)

    subject.perform_async(webhook.id)
  end
end
