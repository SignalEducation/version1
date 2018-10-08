require 'rails_helper'
require 'support/users_and_groups_setup'
require 'support/system_setup'

describe 'The student sign-up process', type: :feature do

  include_context 'users_and_groups_setup'
  include_context 'system_setup'


  before(:each) do
    activate_authlogic

    stripe_monthly_plan = Stripe::Plan.create(amount: (subscription_plan_gbp_m.price.to_f * 100).to_i,
                                              currency: subscription_plan_gbp_m.currency.try(:iso_code).try(:downcase),
                                              interval: 'month',
                                              name: 'LearnSignal Test' + subscription_plan_gbp_m.name.to_s,
                                              interval_count: subscription_plan_gbp_m.payment_frequency_in_months.to_i,
                                              id: Rails.env + '-' + ApplicationController::generate_random_code(20))
    subscription_plan_gbp_m.update_attribute(:stripe_guid, stripe_monthly_plan.id)
    stripe_monthly_plan = Stripe::Plan.create(amount: (subscription_plan_gbp_q.price.to_f * 100).to_i,
                                              currency: subscription_plan_gbp_q.currency.try(:iso_code).try(:downcase),
                                              interval: 'month',
                                              name: 'LearnSignal Test' + subscription_plan_gbp_q.name.to_s,
                                              interval_count: subscription_plan_gbp_q.payment_frequency_in_months.to_i,
                                              id: Rails.env + '-' + ApplicationController::generate_random_code(20))
    subscription_plan_gbp_q.update_attribute(:stripe_guid, stripe_monthly_plan.id)
    stripe_monthly_plan = Stripe::Plan.create(amount: (subscription_plan_gbp_y.price.to_f * 100).to_i,
                                              currency: subscription_plan_gbp_y.currency.try(:iso_code).try(:downcase),
                                              interval: 'month',
                                              name: 'LearnSignal Test' + subscription_plan_gbp_y.name.to_s,
                                              interval_count: subscription_plan_gbp_y.payment_frequency_in_months.to_i,
                                              id: Rails.env + '-' + ApplicationController::generate_random_code(20))
    subscription_plan_gbp_y.update_attribute(:stripe_guid, stripe_monthly_plan.id)

    visit new_student_path
    user_password = ApplicationController.generate_random_code(10)
    within('#new_user') do
      student_sign_up_as('John', 'Smith', 'john@example.com', user_password)
    end
    expect(page).to have_content 'Thanks for Signing Up'

    visit user_verification_path(email_verification_code: User.last.email_verification_code)
    expect(page).to have_content 'Verification Complete'
  end

  describe 'sign-up with to free trial valid details:' do
    describe 'and upgrade to paying plan' do
      scenario 'Monthly GBP', js: true do
        within('.navbar.navbar-default') do
          find('.days-left').click
        end
        expect(page).to have_content I18n.t('views.subscriptions.new_subscription.h1')
        student_picks_a_subscription_plan(gbp, 1)
        enter_credit_card_details('valid')
        within('.check.terms_and_conditions') do
          find('span').click
        end
        click_on I18n.t('views.users.upgrade_subscription.upgrade_subscription')
        sleep(10)
        within('#thank-you-message') do
          expect(page).to have_content 'Thanks for choosing a subscription!'
        end
        visit_my_profile
        click_on I18n.t('views.user_accounts.subscription_info.tab_heading')
        expect(page).to have_content 'Active Subscription'
      end

      scenario 'Quarterly GBP', js: true do
        within('.navbar.navbar-default') do
          find('.days-left').click
        end
        expect(page).to have_content I18n.t('views.subscriptions.new_subscription.h1')
        student_picks_a_subscription_plan(gbp, 3)
        enter_credit_card_details('valid')
        within('.check.terms_and_conditions') do
          find('span').click
        end
        click_on I18n.t('views.users.upgrade_subscription.upgrade_subscription')
        sleep(10)
        within('#thank-you-message') do
          expect(page).to have_content 'Thanks for choosing a subscription!'
        end
        visit_my_profile
        click_on I18n.t('views.user_accounts.subscription_info.tab_heading')
        expect(page).to have_content 'Active Subscription'
      end

      scenario 'Yearly GBP', js: true do
        within('.navbar.navbar-default') do
          find('.days-left').click
        end
        expect(page).to have_content I18n.t('views.subscriptions.new_subscription.h1')
        student_picks_a_subscription_plan(gbp, 12)
        enter_credit_card_details('valid')
        within('.check.terms_and_conditions') do
          find('span').click
        end
        click_on I18n.t('views.users.upgrade_subscription.upgrade_subscription')
        sleep(10)
        within('#thank-you-message') do
          expect(page).to have_content 'Thanks for choosing a subscription!'
        end
        visit_my_profile
        click_on I18n.t('views.user_accounts.subscription_info.tab_heading')
        expect(page).to have_content 'Active Subscription'
      end
    end
  end

end
