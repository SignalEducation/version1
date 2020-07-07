# frozen_string_literal: true

require 'rails_helper'

describe 'A user submitting an exercise', type: :feature do
  let(:country) { create(:country, name: 'United Kingdom') }
  let(:user) { create(:student_user, :with_group, country: country, currency: country.currency) }
  let(:file_path) { Rails.root.join('spec/fixtures/test_exercise_submission.pdf') }

  context 'when the user has a pending exercise' do
    before(:each) do
      mock = create(:product, :for_mock, currency_id: country.currency.id)
      order = create(:order, product_id: mock.id, user_id: user.id)
      create(:exercise, product: mock, user: user, order: order)
      sign_in_via_sign_in_page(user)
    end

    scenario 'can upload an exercise submission file' do
      visit user_exercises_path(user_id: user.id)
      expect(page).to have_content('Start your mock exam')
      click_link 'Begin Exercise'

      page.attach_file('Upload a PDF of your solution', file_path)
      click_button('Upload Submission')

      expect(page).to have_content('Status: submitted')
      expect(page).to have_link('Download Submission')
    end
  end

  context 'when the user has no pending exercises' do
    before(:each) do
      sign_in_via_sign_in_page(user)
    end

    scenario 'they get prompted to purchase an exercise' do
      visit user_exercises_path(user_id: user.id)
      expect(page).to have_content('Purchase an Exercise')
    end
  end
end
