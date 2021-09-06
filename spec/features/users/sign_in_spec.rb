# frozen_string_literal: true

require 'rails_helper'

describe 'Sign in process', type: :feature do
  let(:user_group )      { create(:student_user_group ) }
  let(:student)          { create(:basic_student, :with_group, user_group: user_group) }
  let(:inactive_student) { create(:inactive_student_user, :with_group, user_group: user_group) }

  before :each do
    activate_authlogic
    visit sign_in_path
  end

  context 'User visits the sign in page' do
    scenario 'Loading the sign in page' do
      expect(page).to have_title('Start Studying Today | LearnSignal')
      expect(page).to have_content('Log In')
      expect(page).to have_content('Welcome Back. Login to continue your learning.')

      within('#sign-in') do
        expect(page).to have_selector(:link_or_button, I18n.t('views.general.sign_in'))
      end
    end
  end

  context 'User sign in attempt actions' do
    scenario 'valid login user data' do
      within('#sign-in') do
        fill_in I18n.t('views.user_sessions.form.email'), with: student.email
        fill_in I18n.t('views.user_sessions.form.password'), with: student.password
        click_button I18n.t('views.general.sign_in')
      end

      expect(page).to have_title('Dashboard')
      expect(page).to have_content('Dashboard')
    end

    scenario 'invalid login user data' do
      within('#sign-in') do
        fill_in I18n.t('views.user_sessions.form.email'), with: inactive_student.email
        fill_in I18n.t('views.user_sessions.form.password'), with: inactive_student.password
        click_button I18n.t('views.general.sign_in')
      end

      expect(page).not_to have_title('Dashboard')
      expect(page).to have_content('Your account is not active')
    end
  end
end
