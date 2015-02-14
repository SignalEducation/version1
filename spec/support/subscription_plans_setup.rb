require 'rails_helper'

shared_context 'subscription_plans_setup' do

  # currencies
  let!(:eur) { FactoryGirl.create(:euro) }
  let!(:usd) { FactoryGirl.create(:usd) }
  let!(:gbp) { FactoryGirl.create(:gbp) }

  # countries
  let!(:ireland) { FactoryGirl.create(:ireland, currency_id: eur.id) }
  let!(:uk) { FactoryGirl.create(:uk, currency_id: gbp.id) }
  let!(:usa) { FactoryGirl.create(:usa, currency_id: usd.id) }

  # subscription plans
  let!(:stripe_helper) { StripeMock.create_test_helper }
  let!(:subscription_plan) { FactoryGirl.create(:student_subscription_plan) }
  let!(:stripe_subscription_plan) { StripeMock.start; plan = stripe_helper.create_plan(
          id: subscription_plan.id,
          amount: (subscription_plan.price * 100).to_i);
          subscription_plan.stripe_guid = plan.id;
          subscription_plan.save; subscription_plan.reload;  StripeMock.stop; subscription_plan
  }

end
