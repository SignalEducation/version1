require 'rails_helper'

RSpec.feature 'Admin::Refunds', type: :feature do
  before :each do
    allow_any_instance_of(StripePlanService).to receive(:create_plan)
    allow_any_instance_of(PaypalPlansService).to receive(:create_plan)
    allow_any_instance_of(StripeApiEvent).to receive(:sync_data_from_stripe).and_return(true)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
    allow_any_instance_of(ApplicationController).to receive(:ensure_user_has_access_rights).and_return(true)
    allow_any_instance_of(Refund).to receive(:create_on_stripe).and_return(true)
    allow(ExamBody).to receive(:all_active).and_return(ExamBody.where(id: exam_body_1.id))
  end

  let(:user)                     { create(:user) }
  let!(:group)                   { create(:group) }
  let!(:exam_body_1)             { create(:exam_body, group: group) }
  let!(:student_user_group)      { create(:student_user_group) }
  let!(:basic_student)           { create(:basic_student, user_group: student_user_group, preferred_exam_body_id: exam_body_1.id) }
  let!(:gbp)                     { create(:gbp) }
  let!(:uk)                      { create(:uk, currency: gbp) }
  let!(:uk_vat_code)             { create(:vat_code, country: uk) }
  let!(:uk_vat_rate)             { create(:vat_rate, vat_code: uk_vat_code) }
  let!(:subscription_plan_gbp_m) { 
    create(
      :student_subscription_plan_m,
      currency: gbp, price: 7.50, stripe_guid: 'stripe_plan_guid_m',
      payment_frequency_in_months: 3
    )
  }
  let!(:valid_subscription)     { create(:valid_subscription, user: basic_student,
                                     subscription_plan: subscription_plan_gbp_m,
                                     stripe_customer_id: basic_student.stripe_customer_id ) }
  let!(:invoice_sub)            { create(:invoice, user: basic_student,
                                     subscription_id: valid_subscription.id, issued_at: Time.now, vat_rate: uk_vat_rate, sca_verification_guid: 'guid-1111') }
  let!(:default_card)           { create(:subscription_payment_card, user: basic_student,
                                    is_default_card: true, stripe_card_guid: 'guid_222',
                                    status: 'card-live' ) }
  let!(:charge)                 { create(:charge, user: basic_student,
                                    paid: true, refunded: false, amount_refunded: 0,
                                    subscription: valid_subscription, invoice: invoice_sub,
                                    subscription_payment_card: default_card, currency: gbp,
                                    stripe_guid: 'ch_21334nj453h', amount: 100, status: 'succeeded') }

  context 'Apply subscription refund from management console' do
    scenario 'Refund student subscription' do
      visit user_path(id: basic_student.id)
      expect(page).to have_content("#{basic_student.email}")
      click_link('Subscriptions')
      expect(page).to have_content('Invoices')
      within('#invoices-panel') do
        find_link('View').click
      end
      expect(page).to have_content("Invoice ID: #{invoice_sub.id}")
      within('.invoice-charges') do
        find_link('View').click
      end
      expect(page).to have_content("Charge ID: #{charge.id}")
      find_link('Refund Charge').click
      expect(page).to have_content('New Refund')
      fill_in 'refund_amount', with: 5
      select 'duplicate', from: 'refund[reason]'
      within('#admin-refund-form') do
        page.find('#refund-save-btn', visible: :all).click
      end
      within('#invoices-panel-huge') do
        expect(page).to have_content('Refunds')
      end
    end
  end
end

