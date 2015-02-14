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

  # load Strope Mock helpers
  let!(:stripe_helper) { StripeMock.create_test_helper }

  # subscription plans - Euro - Mth / Qtr / Year
  let!(:subscription_plan_eur_m) { FactoryGirl.create(:student_subscription_plan_m, currency_id: eur.id) }
  let!(:stripe_subscription_plan_eur_m) { StripeMock.start; plan = stripe_helper.create_plan(
          id: subscription_plan_eur_m.id,
          amount: (subscription_plan_eur_m.price * 100).to_i);
          subscription_plan_eur_m.update_attributes(stripe_guid: plan.id)
          subscription_plan_eur_m.reload;  StripeMock.stop
          subscription_plan_eur_m
  }
  let!(:subscription_plan_eur_q) { FactoryGirl.create(:student_subscription_plan_q, currency_id: eur.id) }
  let!(:stripe_subscription_plan_eur_q) { StripeMock.start; plan = stripe_helper.create_plan(
          id: subscription_plan_eur_q.id,
          amount: (subscription_plan_eur_q.price * 100).to_i);
          subscription_plan_eur_q.update_attributes(stripe_guid: plan.id)
          subscription_plan_eur_q.reload;  StripeMock.stop
          subscription_plan_eur_q
  }
  let!(:subscription_plan_eur_y) { FactoryGirl.create(:student_subscription_plan_y, currency_id: eur.id) }
  let!(:stripe_subscription_plan_eur_y) { StripeMock.start; plan = stripe_helper.create_plan(
          id: subscription_plan_eur_y.id,
          amount: (subscription_plan_eur_y.price * 100).to_i);
          subscription_plan_eur_y.update_attributes(stripe_guid: plan.id)
          subscription_plan_eur_y.reload;  StripeMock.stop
          subscription_plan_eur_y
  }

  # subscription plans - USD - Mth / Qtr / Year
  let!(:subscription_plan_usd_m) { FactoryGirl.create(:student_subscription_plan_m, currency_id: usd.id) }
  let!(:stripe_subscription_plan_usd_m) { StripeMock.start; plan = stripe_helper.create_plan(
          id: subscription_plan_usd_m.id,
          amount: (subscription_plan_usd_m.price * 100).to_i);
          subscription_plan_usd_m.update_attributes(stripe_guid: plan.id)
          subscription_plan_usd_m.reload;  StripeMock.stop
          subscription_plan_usd_m
  }
  let!(:subscription_plan_usd_q) { FactoryGirl.create(:student_subscription_plan_q, currency_id: usd.id) }
  let!(:stripe_subscription_plan_usd_q) { StripeMock.start; plan = stripe_helper.create_plan(
          id: subscription_plan_usd_q.id,
          amount: (subscription_plan_usd_q.price * 100).to_i);
          subscription_plan_usd_q.update_attributes(stripe_guid: plan.id)
          subscription_plan_usd_q.reload;  StripeMock.stop
          subscription_plan_usd_q
  }
  let!(:subscription_plan_usd_y) { FactoryGirl.create(:student_subscription_plan_y, currency_id: usd.id) }
  let!(:stripe_subscription_plan_usd_y) { StripeMock.start; plan = stripe_helper.create_plan(
          id: subscription_plan_usd_y.id,
          amount: (subscription_plan_usd_y.price * 100).to_i);
          subscription_plan_usd_y.update_attributes(stripe_guid: plan.id)
          subscription_plan_usd_y.reload;  StripeMock.stop
          subscription_plan_usd_y
  }

  # subscription plans - GBP - Mth / Qtr / Year
  let!(:subscription_plan_gbp_m) { FactoryGirl.create(:student_subscription_plan_m, currency_id: gbp.id) }
  let!(:stripe_subscription_plan_gbp_m) { StripeMock.start; plan = stripe_helper.create_plan(
          id: subscription_plan_gbp_m.id,
          amount: (subscription_plan_gbp_m.price * 100).to_i);
          subscription_plan_gbp_m.update_attributes(stripe_guid: plan.id)
          subscription_plan_gbp_m.reload;  StripeMock.stop
          subscription_plan_gbp_m
  }
  let!(:subscription_plan_gbp_q) { FactoryGirl.create(:student_subscription_plan_q, currency_id: gbp.id) }
  let!(:stripe_subscription_plan_gbp_q) { StripeMock.start; plan = stripe_helper.create_plan(
          id: subscription_plan_gbp_q.id,
          amount: (subscription_plan_gbp_q.price * 100).to_i);
          subscription_plan_gbp_q.update_attributes(stripe_guid: plan.id)
          subscription_plan_gbp_q.reload;  StripeMock.stop
          subscription_plan_gbp_q
  }
  let!(:subscription_plan_gbp_y) { FactoryGirl.create(:student_subscription_plan_y, currency_id: gbp.id) }
  let!(:stripe_subscription_plan_gbp_y) { StripeMock.start; plan = stripe_helper.create_plan(
          id: subscription_plan_gbp_y.id,
          amount: (subscription_plan_gbp_y.price * 100).to_i);
          subscription_plan_gbp_y.update_attributes(stripe_guid: plan.id)
          subscription_plan_gbp_y.reload;  StripeMock.stop
          subscription_plan_gbp_y
  }

end
