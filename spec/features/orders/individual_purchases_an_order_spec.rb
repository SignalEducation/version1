# frozen_string_literal: true

require 'rails_helper'

describe 'An individual purchasing a product', type: :feature do
  let!(:country) { create(:country, name: 'United Kingdom') }
  let!(:user) { create(:student_user, country: country, currency: country.currency) }
  let!(:mock) { create(:product, :for_mock, currency_id: country.currency.id) }
  let!(:correction) { create(:product, :for_corrections, currency_id: country.currency.id) }

  context 'as a logged-in user' do
    before(:each) do
      activate_authlogic
      sign_in_via_sign_in_page(user)
    end

    scenario 'can browse available products', js: true do
      visit prep_products_path

      expect(page).to have_content(mock.mock_exam.name)

      click_link 'Correction Packs'

      expect(page).to have_content(correction.mock_exam.name)
    end

    scenario 'can checkout using PayPal', js: true do
      sleep(3)
      visit prep_products_path
      first(:link, mock.mock_exam.name).click

      expect(page).to have_content('Choose a way to pay')

      element = find('label[for=pay-with-paypal]')
      scroll_to(element)
      element.click

      expect(page).to have_selector('#paypal_submit')
    end

    xscenario 'can purchase a product with Stripe', js: true do
      allow_any_instance_of(StripeService).to(
        receive(:create_payment_intent).
        and_return(
          double(customer: 'cus_12324', id: 'intent_1234', client_secret: 'cs_1234456', status: 'succeeded')
        )
      )
      visit prep_products_path
      first(:link, mock.mock_exam.name).click

      expect(page).to have_content('Choose a way to pay')

      sleep(5)
      fill_stripe_elements
      click_button('Purchase Now')

      expect(page).to have_content('Pending Exercises')
      expect(page).to have_current_path(user_exercises_path(user_id: user.id))
    end
  end

  context 'as a logged-out user' do
    scenario 'can browse available products' do
      visit prep_products_path

      expect(page).to have_content(mock.mock_exam.name)

      click_link 'Correction Packs'

      expect(page).to have_content(correction.mock_exam.name)
    end

    scenario 'attempting to purchase prompts a sign-up or login' do
      visit prep_products_path
      first(:link, mock.mock_exam.name).click

      expect(page).to have_content('Register')
      expect(page).to have_button('Register Now')
      expect(page).to have_content('Log In')
    end
  end
end
