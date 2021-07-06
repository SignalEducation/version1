require 'rails_helper'

RSpec.feature 'Admin::SubscriptionCancellations', type: :feature do
  before :each do
    allow_any_instance_of(StripePlanService).to receive(:create_plan)
    allow_any_instance_of(PaypalPlansService).to receive(:create_plan)
    allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(user)
    allow_any_instance_of(ApplicationController).to receive(:logged_in_required).and_return(true)
    allow_any_instance_of(ApplicationController).to receive(:ensure_user_has_access_rights).and_return(true)
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
  let!(:valid_subscription)      { create(:valid_subscription, user: basic_student,
                                     subscription_plan: subscription_plan_gbp_m,
                                     state: 'active',
                                     stripe_customer_id: basic_student.stripe_customer_id ) }

  context 'Cancel subscription from management console' do
    scenario 'Cancel student subscription standard', js: true do
      expect_any_instance_of(SubscriptionService).to receive(:cancel_subscription).and_return(true)
      visit user_path(id: basic_student.id)
      expect(page).to have_content("#{basic_student.email}")
      click_link('Subscriptions')
      expect(page).to have_content('Invoices')
      within('#admin-user-subscription') do
        find_link(I18n.t('views.general.view')).click
      end
      expect(page).to have_content("Subscription ID: #{valid_subscription.id}")
      find('#admin-cancel-subscription').click
      wait = Selenium::WebDriver::Wait.new ignore: Selenium::WebDriver::Error::NoAlertPresentError
      alert = wait.until { page.driver.browser.switch_to.alert }
      alert.accept
      expect(page).to have_content('Standard Cancellation')
      choose(option: 'Duplicate Payment')
      page.find('#confirm_cancellation_button', visible: :all).click
      expect(page).to have_content('Subscription has been cancelled')
    end

    scenario 'Cancel student subscription immediately', js: true do
      expect_any_instance_of(SubscriptionService).to receive(:cancel_subscription_immediately).and_return(true)
      visit user_path(id: basic_student.id)
      expect(page).to have_content("#{basic_student.email}")
      click_link('Subscriptions')
      expect(page).to have_content('Invoices')
      within('#admin-user-subscription') do
        find_link(I18n.t('views.general.view')).click
      end
      expect(page).to have_content("Subscription ID: #{valid_subscription.id}")
      find('#admin-cancel-immediately').click
      wait = Selenium::WebDriver::Wait.new ignore: Selenium::WebDriver::Error::NoAlertPresentError
      alert = wait.until { page.driver.browser.switch_to.alert }
      alert.accept
      expect(page).to have_content('Immediate Cancellation')
      choose(option: 'Duplicate Payment')
      page.find('#confirm_cancellation_button', visible: :all).click
      expect(page).to have_content('Subscription has been cancelled')
    end
  end
end

