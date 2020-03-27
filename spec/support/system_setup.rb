require 'rails_helper'

shared_context 'system_setup' do

  # Top-level Course Content
  let!(:exam_body_1) { FactoryBot.create(:exam_body) }
  let!(:group_1) { FactoryBot.create(:group) }
  let!(:group_2) { FactoryBot.create(:group) }
  let!(:course_1)  { FactoryBot.create(:active_course,
                                                group_id: group_1.id,
                                                exam_body_id: exam_body_1.id) }
  let!(:course_2)  { FactoryBot.create(:active_course,
                                                group_id: group_1.id,
                                                computer_based: true,
                                                exam_body_id: exam_body_1.id) }
  let!(:preview_course)  { FactoryBot.create(:preview_course,
                                                      group_id: group_1.id,
                                                      exam_body_id: exam_body_1.id) }

  let!(:standard_exam_sitting)  { FactoryBot.create(:standard_exam_sitting,
                                                    course_id: course_1.id) }
  let!(:computer_based_exam_sitting)  { FactoryBot.create(:computer_based_exam_sitting,
                                                    course_id: course_2.id) }


  # homepages
  let!(:home) { FactoryBot.create(:home, group_id: group_1.id) }
  let!(:landing_page_1) { FactoryBot.create(:landing_page_1,
                                             group_id: group_1.id) }
  let!(:landing_page_2) { FactoryBot.create(:landing_page_2,
                                             course_id: course_1.id,
                                             group_id: nil) }

  # currencies
  let!(:gbp) { FactoryBot.create(:gbp) }
  let!(:eur) { FactoryBot.create(:euro) }
  let!(:usd) { FactoryBot.create(:usd) }
  let!(:mxn) { FactoryBot.create(:mxn) }

  # countries
  let!(:uk) { FactoryBot.create(:uk, currency_id: gbp.id) }
  let!(:ireland) { FactoryBot.create(:ireland, currency_id: eur.id) }
  let!(:usa) { FactoryBot.create(:usa, currency_id: usd.id) }
  let!(:fr) { FactoryBot.create(:fr, currency_id: eur.id) }

  # vat codes
  let!(:uk_vat_code) { FactoryBot.create(:vat_code, country_id: uk.id) }
  let!(:ireland_vat_code) { FactoryBot.create(:vat_code, country_id: ireland.id) }
  let!(:usa_vat_code) { FactoryBot.create(:vat_code, country_id: usa.id) }




  # subscription plans - GBP - Mth / Qtr / Year
  let!(:subscription_plan_gbp_m) { FactoryBot.create(:student_subscription_plan_m,
                                                      currency_id: gbp.id, price: 7.50) }
  let!(:subscription_plan_gbp_q) { FactoryBot.create(:student_subscription_plan_q,
                                                      currency_id: gbp.id, price: 22.50) }
  let!(:subscription_plan_gbp_y) { FactoryBot.create(:student_subscription_plan_y,
                                                      currency_id: gbp.id, price: 87.99) }

  # subscription plans - Euro - Mth / Qtr / Year
  let!(:subscription_plan_eur_m) { FactoryBot.create(:student_subscription_plan_m,
                                                      currency_id: eur.id, price: 10) }
  let!(:subscription_plan_eur_q) { FactoryBot.create(:student_subscription_plan_q,
                                                      currency_id: eur.id, price: 30) }
  let!(:subscription_plan_eur_y) { FactoryBot.create(:student_subscription_plan_y,
                                                      currency_id: eur.id, price: 120) }

  # subscription plans - USD - Mth / Qtr / Year
  let!(:subscription_plan_usd_m) { FactoryBot.create(:student_subscription_plan_m,
                                                      currency_id: usd.id, price: 11.50) }
  let!(:subscription_plan_usd_q) { FactoryBot.create(:student_subscription_plan_q,
                                                      currency_id: usd.id, price: 35) }
  let!(:subscription_plan_usd_y) { FactoryBot.create(:student_subscription_plan_y,
                                                      currency_id: usd.id, price: 134.99) }

end
