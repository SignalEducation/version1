require 'rails_helper'
require 'support/users_and_groups_setup'

require 'support/course_content'
require 'support/system_setup'

describe 'The student sign-up process', type: :feature do

  include_context 'users_and_groups_setup'

  include_context 'course_content'
  include_context 'system_setup'

  after { StripeMock.stop }

  before(:each) do
    activate_authlogic
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
        # Getting rejected by Stripe because we aren't sending existing SubscriptionPlan Item
        click_on I18n.t('views.users.upgrade_subscription.upgrade_subscription')
        sleep(10)
        within('#thank-you-message') do
          expect(page).to have_content 'Thanks for upgrading your subscription!'
        end
        visit_my_profile
        click_on I18n.t('views.users.show.tabs.subscriptions')
        expect(page).to have_content 'Account Status Active Subscription'
        expect(page).to have_content 'Billing Interval Monthly'
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
          expect(page).to have_content 'Thanks for upgrading your subscription!'
        end
        visit_my_profile
        click_on I18n.t('views.users.show.tabs.subscriptions')
        expect(page).to have_content 'Account Status Active Subscription'
        expect(page).to have_content 'Billing Interval Quarterly'
      end

      scenario 'Yearly GBP', js: true do
        within('.navbar.navbar-default') do
          find('.days-left').click
        end
        expect(page).to have_content I18n.t('views.subscriptions.new_subscription.h1')
        student_picks_a_subscription_plan(gbp, 12)
        enter_credit_card_details('valid')
        check(I18n.t('views.general.terms_and_conditions'))
        click_on I18n.t('views.users.upgrade_subscription.upgrade_subscription')
        sleep(10)
        within('#thank-you-message') do
          expect(page).to have_content 'Thanks for upgrading your subscription!'
        end
        visit_my_profile
        click_on I18n.t('views.users.show.tabs.subscriptions')
        expect(page).to have_content 'Account Status Active Subscription'
        expect(page).to have_content 'Billing Interval Yearly'
      end
    end
  end

end
