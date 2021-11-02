# frozen_string_literal: true

require 'rails_helper'

describe 'An individual purchasing a product', type: :feature do
  let!(:country) { create(:country, name: 'United Kingdom') }
  let!(:exam_body) { FactoryBot.create(:exam_body) }
  let!(:group) { FactoryBot.create(:group, exam_body: exam_body) }
  let!(:user) { create(:student_user, country: country, currency: country.currency, preferred_exam_body: exam_body) }
  let!(:mock) { create(:product, :for_mock, currency_id: country.currency.id) }
  let!(:correction) { create(:product, :for_corrections, currency_id: country.currency.id) }

  context 'as a logged-in user' do
    before(:each) do
      activate_authlogic
      sign_in_via_sign_in_page(user)
      visit prep_products_path
    end

    scenario 'can browse available products' do
      expect(page).to have_content(mock.mock_exam.name)

      click_link 'Correction Packs'

      expect(page).to have_content(correction.mock_exam.name)
    end

    scenario 'can checkout using PayPal' do
      first(:link, mock.mock_exam.name).click

      expect(page).to have_content('Pay with PayPal')
      expect(page).to have_selector('#paypal_submit')
    end

    scenario 'can purchase a product with Stripe' do
      allow_any_instance_of(StripeService).to(
        receive(:create_payment_intent).
        and_return(
          double(customer: 'cus_12324', id: 'intent_1234', client_secret: 'cs_1234456', status: 'succeeded')
        )
      )
      visit prep_products_path
      first(:link, mock.mock_exam.name).click

      expect(page).to have_content('Pay with Card')
      expect(page).to have_selector('#pay-with-card')
    end
  end
end
