# frozen_string_literal: true

require 'rails_helper'

describe 'A user cancels a subscription', type: :feature do
  let(:country) { create(:country, name: 'United Kingdom') }
  let(:user) { create(:student_user, :with_group, country: country, currency: country.currency) }

  context 'with an existing subscription' do
    before(:each) do
      allow_any_instance_of(StripePlanService).to receive(:create_plan)
      allow_any_instance_of(PaypalPlansService).to receive(:create_plan)
      allow_any_instance_of(Subscription).to receive(:cancel_by_user).and_return(true)
      create(:valid_subscription, user: user, state: 'active')
      sign_in_via_sign_in_page(user)
      visit account_path
    end

    scenario 'the user can keep the subscription' do
      expect(page).to have_content('My Account')
      click_link 'Subscriptions'
      find(:css, '.sub-details').click
      click_link 'Cancel Subscription'
    end

    scenario 'the user can cancel' do
      expect(page).to have_content('My Account')
      click_link 'Subscriptions'
      find(:css, '.sub-details').click
      click_link 'Cancel Subscription'
      choose 'The service is too expensive'
      click_button 'Cancel My Subscription'

      expect(page).to have_content('Your Subscription has been cancelled')
      expect(page).to have_content('My Account')
    end

    xscenario 'the user must give a reason for cancelling' do
      expect(page).to have_content('My Account')
      click_link 'Subscriptions'
      find(:css, '.sub-details').click
      click_link 'Cancel Subscription'
      click_button 'Cancel My Subscription'

      expect(page).to have_content("Please tell us why you're cancelling")
    end
  end
end
