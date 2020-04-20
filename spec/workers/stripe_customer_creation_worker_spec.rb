# frozen_string_literal: true

require 'rails_helper'
require 'sidekiq/testing'

RSpec.describe StripeCustomerCreationWorker do
  let(:user) { create(:user) }
  before do
    Sidekiq::Testing.fake!
    Sidekiq::Worker.clear_all
    customer_double = double(id: 'cus_12345')
    allow(Stripe::Customer).to receive(:create).and_return(customer_double)
  end

  after do
    Sidekiq::Worker.drain_all
  end

  subject { StripeCustomerCreationWorker }

  it 'Event Importer job is processed in importers queue.' do
    expect { subject.perform_async(user.id) }.to change(subject.jobs, :size).by(1)
  end

  it 'calls #create_customer on an instance of StripeService' do
    expect_any_instance_of(StripeService).to receive(:create_customer!).with(user)

    subject.perform_async(user.id)
  end
end
