# frozen_string_literal: true

require 'rails_helper'

describe 'An individual purchasing a product', type: :feature do
  let!(:country) { create(:country, name: 'United Kingdom') }
  let!(:mock) { create(:product, :for_mock, currency_id: country.currency.id) }
  let!(:correction) { create(:product, :for_corrections, currency_id: country.currency.id) }
  let!(:exam_body) { FactoryBot.create(:exam_body) }
  let!(:group) { FactoryBot.create(:group, exam_body: exam_body) }

  before :each do
    visit prep_products_path
  end

  context 'as an existing user' do
    let(:user) { create(:student_user, country: country, currency: country.currency, preferred_exam_body: exam_body) }

    scenario 'the user sees the product once they login' do
      first(:link, mock.mock_exam.name).click
      within('.register-login-nav') do
        click_link('Log In')
      end
      fill_in I18n.t('views.user_sessions.form.email'), with: user.email
      fill_in I18n.t('views.user_sessions.form.password'), with: user.password
      click_button('Log In')

      expect(page).to have_content(mock.mock_exam.name)
      expect(page).to have_content('Pay with Card')
    end
  end

  context 'as a new user' do
    let(:user) { build(:student_user) }

    scenario 'the user sees the product once they register' do
      allow_any_instance_of(User).to receive(:create_stripe_customer)
      first(:link, mock.mock_exam.name).click
      within('.register-login-nav') do
        click_link('Register')
      end

      fill_in 'user_first_name', with: user.first_name
      fill_in 'user_last_name', with: user.last_name
      fill_in 'user_email', with: user.email
      fill_in 'user_password', with: 'pass1234'
      fill_in 'user_password_confirmation', with: 'pass1234'
      find('label[for=terms_and_conditions]').click
      find('label[for=communication_approval]').click

      click_button 'Register Now'

      expect(page).to have_content(correction.mock_exam.name)
    end
  end
end
