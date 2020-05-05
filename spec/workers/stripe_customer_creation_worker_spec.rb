# frozen_string_literal: true

require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe StripeCustomerCreationWorker do
  let(:user) { create(:user) }
  before do
    Sidekiq::Testing.fake!
    Sidekiq::Worker.clear_all
  end

  after do
    Sidekiq::Worker.drain_all
  end

  subject { StripeCustomerCreationWorker }

  it 'Event Importer job is processed in importers queue.' do
    allow_any_instance_of(StripeService).to receive(:create_customer!).with(user)

    expect { subject.perform_async(user.id) }.to change(subject.jobs, :size).by(1)
  end

  it 'calls the #create_customer! action on the StripeService' do
    expect_any_instance_of(StripeService).to receive(:create_customer!).with(user)

    expect { subject.perform_async(user.id) }.to change(subject.jobs, :size).by(1)
  end
end
