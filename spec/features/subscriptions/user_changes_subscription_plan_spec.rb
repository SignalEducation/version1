# frozen_string_literal: true

require 'rails_helper'

describe 'A user changes subscription plans', type: :feature do
  let(:country) { create(:country, name: 'United Kingdom') }
  let(:user) { create(:student_user, :with_group, country: country, currency: country.currency) }
  let(:plan) { create(:student_subscription_plan_m, exam_body: user.preferred_exam_body, currency: country.currency) }

  before(:each) do
    allow_any_instance_of(StripePlanService).to receive(:create_plan)
    allow_any_instance_of(PaypalPlansService).to receive(:create_plan)
    create(:student_subscription_plan_y, currency: country.currency, exam_body: user.preferred_exam_body)
    create(:subscription_payment_card, user: user, account_country: country)
  end

  context 'for users with a subscription' do
    let!(:subscription) { create(:stripe_subscription, subscription_plan: plan, user: user, state: 'active') }

    before(:each) do
      sign_in_via_sign_in_page(user)
      visit account_path
    end

    scenario 'the user can view other subscription plans' do
      expect(page).to have_content('Profile')
      click_link 'Account Info'
      find(:css, '.sub-details').click
      click_link 'Change Subscription Plan'

      expect(page).to have_content('Change Plan')
      expect(page).to have_content('Select your preferred payment plan')
    end

    context 'for Stripe subscriptions' do
      # this needs to be run with { js: true } which is not currently possible with the
      # authlogic issues. It passes locally and passed on CI when it feels like it
      xscenario 'the user can get to the change plans card input screen' do
        allow_any_instance_of(StripeSubscriptionService).to receive(:retrieve_subscription).and_return({cancel_at_period_end: false})
        allow_any_instance_of(StripeSubscriptionService).to receive(:change_plan).and_return([subscription, { status: :ok }])
        expect(page).to have_content('Profile')
        click_link 'Account Info'
        find(:css, '.sub-details').click
        click_link 'Change Subscription Plan'
        click_button 'Change Plan Now'

        expect(page).to have_content('Thank you for subscribing')
      end
    end
  end
end
