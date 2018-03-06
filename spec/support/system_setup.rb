require 'rails_helper'
require 'stripe_mock'

shared_context 'system_setup' do

  # Top-level Course Content
  let!(:exam_body_1) { FactoryGirl.create(:exam_body) }
  let!(:group_1) { FactoryGirl.create(:group) }
  let!(:subject_course_1)  { FactoryGirl.create(:active_subject_course,
                                                group_id: group_1.id,
                                                exam_body_id: exam_body_1.id) }
  let!(:preview_subject_course)  { FactoryGirl.create(:preview_subject_course,
                                                      group_id: group_1.id,
                                                      exam_body_id: exam_body_1.id) }


  # homepages
  let!(:home) { FactoryGirl.create(:home, group_id: group_1.id) }
  let!(:landing_page_1) { FactoryGirl.create(:landing_page_1,
                                             group_id: group_1.id) }
  let!(:landing_page_2) { FactoryGirl.create(:landing_page_2,
                                             subject_course_id: subject_course_1.id,
                                             group_id: nil) }

  # currencies
  let!(:gbp) { FactoryGirl.create(:gbp) }
  let!(:eur) { FactoryGirl.create(:euro) }
  let!(:usd) { FactoryGirl.create(:usd) }

  # countries
  let!(:uk) { FactoryGirl.create(:uk, currency_id: gbp.id) }
  let!(:ireland) { FactoryGirl.create(:ireland, currency_id: eur.id) }
  let!(:usa) { FactoryGirl.create(:usa, currency_id: usd.id) }

  # vat codes
  let!(:uk_vat_code) { FactoryGirl.create(:vat_code, country_id: uk.id) }
  let!(:ireland_vat_code) { FactoryGirl.create(:vat_code, country_id: ireland.id) }
  let!(:usa_vat_code) { FactoryGirl.create(:vat_code, country_id: usa.id) }


  # user groups
  let!(:student_user_group ) { FactoryGirl.create(:student_user_group ) }
  let(:tutor_user_group) { FactoryGirl.create(:tutor_user_group) }
  let(:content_manager_user_group) { FactoryGirl.create(:content_manager_user_group) }
  let(:admin_user_group) { FactoryGirl.create(:admin_user_group) }
  let(:complimentary_user_group) { FactoryGirl.create(:complimentary_user_group) }
  let(:marketing_manager_user_group) { FactoryGirl.create(:marketing_manager_user_group) }
  let(:customer_support_user_group) { FactoryGirl.create(:customer_support_user_group) }
  let(:blocked_user_group) { FactoryGirl.create(:blocked_user_group) }




  # subscription plans - GBP - Mth / Qtr / Year
  let!(:subscription_plan_gbp_m) { FactoryGirl.create(:student_subscription_plan_m,
                                                      currency_id: gbp.id, price: 7.50) }
  let!(:subscription_plan_gbp_q) { FactoryGirl.create(:student_subscription_plan_q,
                                                      currency_id: gbp.id, price: 22.50) }
  let!(:subscription_plan_gbp_y) { FactoryGirl.create(:student_subscription_plan_y,
                                                      currency_id: gbp.id, price: 87.99) }

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

end
