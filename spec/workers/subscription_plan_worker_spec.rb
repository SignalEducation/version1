# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubscriptionPlanWorker do
  let(:plan) do
    build_stubbed(:subscription_plan, stripe_guid: 'stripe_plan_12345678', paypal_guid: 'paypal_plan_12345678')
  end

  before do
    Sidekiq::Testing.fake!
    Sidekiq::Worker.clear_all
  end

  after do
    Sidekiq::Worker.drain_all
  end

  subject { SubscriptionPlanWorker }

  it 'processes the job in the high queue' do
    allow_any_instance_of(StripePlanService).to receive(:delete_plan).with('stripe_plan_12345678')
    allow_any_instance_of(PaypalPlansService).to receive(:delete_plan).with('paypal_plan_12345678')

    expect { subject.perform_async(plan.id, 'delete', plan.stripe_guid, plan.paypal_guid) }.to change(subject.jobs, :size).by(1)
  end

  it 'calls for the deletion of the Stripe and PayPal plans if the action specified is DELETE' do
    expect_any_instance_of(StripePlanService).to receive(:delete_plan).with('stripe_plan_12345678')
    expect_any_instance_of(PaypalPlansService).to receive(:delete_plan).with('paypal_plan_12345678')

    subject.perform_async(plan.id, 'delete', plan.stripe_guid, plan.paypal_guid)
  end

  it 'calls #async_action on an instance of SubscriptionPlanService if the acition is not DELETE' do
    allow(SubscriptionPlan).to receive(:find).with(plan.id).and_return(plan)
    expect_any_instance_of(SubscriptionPlanService).to receive(:async_action).with('test_action')

    subject.perform_async(plan.id, 'test_action', plan.stripe_guid, plan.paypal_guid)
  end
end
