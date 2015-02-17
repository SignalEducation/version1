require 'rails_helper'
require 'stripe_mock'

shared_context 'subscription_plans_setup' do

  # currencies
  let!(:eur) { FactoryGirl.create(:euro) }
  let!(:usd) { FactoryGirl.create(:usd) }
  let!(:gbp) { FactoryGirl.create(:gbp) }

  # countries
  let!(:ireland) { FactoryGirl.create(:ireland, currency_id: eur.id) }
  let!(:uk) { FactoryGirl.create(:uk, currency_id: gbp.id) }
  let!(:usa) { FactoryGirl.create(:usa, currency_id: usd.id) }

  # load Stripe Mock helpers
  let!(:stripe_helper) { StripeMock.create_test_helper }

  # subscription plans - Euro - Mth / Qtr / Year
  let!(:subscription_plan_eur_m) { FactoryGirl.create(:student_subscription_plan_m,
                                   currency_id: eur.id, price: 10) }
  let!(:subscription_plan_eur_q) { FactoryGirl.create(:student_subscription_plan_q,
                                   currency_id: eur.id, price: 30) }
  let!(:subscription_plan_eur_y) { FactoryGirl.create(:student_subscription_plan_y,
                                   currency_id: eur.id, price: 120) }

  # subscription plans - USD - Mth / Qtr / Year
  let!(:subscription_plan_usd_m) { FactoryGirl.create(:student_subscription_plan_m,
                                   currency_id: usd.id, price: 11.50) }
  let!(:subscription_plan_usd_q) { FactoryGirl.create(:student_subscription_plan_q,
                                   currency_id: usd.id, price: 35) }
  let!(:subscription_plan_usd_y) { FactoryGirl.create(:student_subscription_plan_y,
                                   currency_id: usd.id, price: 134.99) }

  # subscription plans - GBP - Mth / Qtr / Year
  let!(:subscription_plan_gbp_m) { FactoryGirl.create(:student_subscription_plan_m,
                                   currency_id: gbp.id, price: 7.50) }
  let!(:subscription_plan_gbp_q) { FactoryGirl.create(:student_subscription_plan_q,
                                   currency_id: gbp.id, price: 22.50) }
  let!(:subscription_plan_gbp_y) { FactoryGirl.create(:student_subscription_plan_y,
                                   currency_id: gbp.id, price: 87.99) }

end
