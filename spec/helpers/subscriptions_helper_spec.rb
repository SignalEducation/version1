# frozen_string_literal: true

require 'rails_helper'

describe SubscriptionsHelper, type: :helper do
  let(:subscription_plan1) { create(:subscription_plan) }
  let(:subscription_plan2) { create(:subscription_plan) }
  let(:subscription)       { create(:subscription, subscription_plan: subscription_plan1) }

  before do
    allow_any_instance_of(SubscriptionPlanService).to receive(:create_remote_plans).and_return(:ok)
  end

  describe '#plans_partials' do
    context 'returns product link to a logged user' do
      it 'return specific plan' do
        params = { prioritise_plan_frequency: SubscriptionPlan::PAYMENT_FREQUENCIES.sample }

        expect(plans_partials(params, subscription, SubscriptionPlan.all)).to include('Billed every month')
      end
    end
  end
end
