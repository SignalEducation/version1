require 'rails_helper'

shared_context 'system_setup' do

  # Top-level Course Content
  let!(:exam_body_1) { create(:exam_body) }
  let!(:group_1) { create(:group, exam_body_id: exam_body_1.id) }
  let!(:group_2) { create(:group, exam_body_id: exam_body_1.id) }
  let!(:course_1)  { create(:active_course,
                            group_id: group_1.id,
                            exam_body_id: exam_body_1.id) }
  let!(:course_2)  { create(:active_course,
                            group_id: group_1.id,
                            computer_based: true,
                            exam_body_id: exam_body_1.id) }
  let!(:preview_course)  { create(:preview_course,
                                  group_id: group_1.id,
                                  exam_body_id: exam_body_1.id) }

  let!(:standard_exam_sitting)  { create(:standard_exam_sitting,
                                         course_id: course_1.id,
                                         exam_body: exam_body_1) }
  let!(:computer_based_exam_sitting)  { create(:computer_based_exam_sitting,
                                               course_id: course_2.id,
                                               exam_body: exam_body_1) }


  # homepages
  let!(:home) { create(:home, group_id: group_1.id) }
  let!(:landing_page_1) { create(:landing_page_1, group_id: group_1.id) }
  let!(:landing_page_2) { create(:landing_page_2, course_id: course_1.id, group_id: nil) }

  # currencies
  let!(:gbp) { create(:gbp) }
  let!(:eur) { create(:euro) }
  let!(:usd) { create(:usd) }
  let!(:mxn) { create(:mxn) }

  # countries
  let!(:uk) { create(:uk, currency_id: gbp.id) }
  let!(:ireland) { create(:ireland, currency_id: eur.id) }
  let!(:usa) { create(:usa, currency_id: usd.id) }
  let!(:fr) { create(:fr, currency_id: eur.id) }

  # vat codes
  let!(:uk_vat_code) { create(:vat_code, country_id: uk.id) }
  let!(:ireland_vat_code) { create(:vat_code, country_id: ireland.id) }
  let!(:usa_vat_code) { create(:vat_code, country_id: usa.id) }


  # subscription plans - GBP - Mth / Qtr / Year
  let!(:subscription_plan_gbp_m) { create(:student_subscription_plan_m, currency_id: gbp.id, price: 7.50, exam_body: exam_body_1) }
  let!(:subscription_plan_gbp_q) { create(:student_subscription_plan_q, currency_id: gbp.id, price: 22.50, exam_body: exam_body_1) }
  let!(:subscription_plan_gbp_y) { create(:student_subscription_plan_y, currency_id: gbp.id, price: 87.99, exam_body: exam_body_1) }

  # subscription plans - Euro - Mth / Qtr / Year
  let!(:subscription_plan_eur_m) { create(:student_subscription_plan_m, currency_id: eur.id, price: 10, exam_body: exam_body_1) }
  let!(:subscription_plan_eur_q) { create(:student_subscription_plan_q, currency_id: eur.id, price: 30, exam_body: exam_body_1) }
  let!(:subscription_plan_eur_y) { create(:student_subscription_plan_y, currency_id: eur.id, price: 120, exam_body: exam_body_1) }

  # subscription plans - USD - Mth / Qtr / Year
  let!(:subscription_plan_usd_m) { create(:student_subscription_plan_m, currency_id: usd.id, price: 11.50, exam_body: exam_body_1) }
  let!(:subscription_plan_usd_q) { create(:student_subscription_plan_q, currency_id: usd.id, price: 35, exam_body: exam_body_1) }
  let!(:subscription_plan_usd_y) { create(:student_subscription_plan_y, currency_id: usd.id, price: 134.99, exam_body: exam_body_1) }

  # products
  let!(:product_lifetime_gbp) { create(:product, :for_lifetime_access, group: group_1, currency_id: gbp.id) }
  let!(:product_lifetime_eur) { create(:product, :for_lifetime_access, group: group_1, currency_id: eur.id) }
  let!(:product_lifetime_usd) { create(:product, :for_lifetime_access, group: group_1, currency_id: usd.id) }
end
