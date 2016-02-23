require 'rails_helper'
require 'support/users_and_groups_setup'
require 'support/subscription_plans_setup'
require 'support/course_content'

describe 'The student sign-up process', type: :feature do

  include_context 'users_and_groups_setup'
  include_context 'subscription_plans_setup'
  include_context 'course_content'

  after { StripeMock.stop }

  before(:each) do
    activate_authlogic
    visit root_path
    user_password = ApplicationController.generate_random_code(10)
    within('#sign-up-form') do
      student_sign_up_as('John', 'Smith', 'john@example.com', user_password, true)
    end
    within('#thank-you-message') do
      expect(page).to have_content 'Final Step!'
    end
  end

  #Todo This needs to be replicated for EUR and GBP
  describe 'sign-up with to free trial valid details:' do
    describe 'and upgrade to paying plan' do
      scenario 'Monthly USD', js: true do
        within('.navbar.navbar-default') do
          find('.days-left').click
        end
        expect(page).to have_content 'Upgrade your membership'
        student_picks_a_subscription_plan(usd, 1)
        enter_credit_card_details('valid')
        find('.upgrade-sub').click
        sleep(10)
        within('#thank-you-message') do
          expect(page).to have_content 'Thanks for upgrading your subscription!'
        end
        visit_my_profile
        click_on 'Subscriptions'
        expect(page).to have_content 'Billing Interval:   Monthly'
      end

      scenario 'Quarterly USD', js: true do
        within('.navbar.navbar-default') do
          find('.days-left').click
        end
        expect(page).to have_content 'Upgrade your membership'
        student_picks_a_subscription_plan(usd, 3)
        enter_credit_card_details('valid')
        find('.upgrade-sub').click
        sleep(10)
        within('#thank-you-message') do
          expect(page).to have_content 'Thanks for upgrading your subscription!'
        end
        visit_my_profile
        click_on 'Subscriptions'
        expect(page).to have_content 'Billing Interval:   Quarterly'
      end

      scenario 'Yearly USD', js: true do
        within('.navbar.navbar-default') do
          find('.days-left').click
        end
        expect(page).to have_content 'Upgrade your membership'
        student_picks_a_subscription_plan(usd, 12)
        enter_credit_card_details('valid')
        find('.upgrade-sub').click
        sleep(10)
        within('#thank-you-message') do
          expect(page).to have_content 'Thanks for upgrading your subscription!'
        end
        visit_my_profile
        click_on 'Subscriptions'
        expect(page).to have_content 'Billing Interval:   Yearly'
      end
    end
  end

end
