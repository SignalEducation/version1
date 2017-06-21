require 'rails_helper'
require 'support/users_and_groups_setup'
require 'support/subscription_plans_setup'
require 'support/system_setup'
require 'support/course_content'

describe 'The email verification process', type: :feature do

  include_context 'users_and_groups_setup'
  include_context 'subscription_plans_setup'
  include_context 'system_setup'
  include_context 'course_content'

  after { StripeMock.stop }

  before(:each) do
    activate_authlogic
    visit root_path
  end

  describe 'after sign up visit user_verification url' do
    scenario 'with a valid verification code', js: false do
      visit user_verification_path(email_verification_code: unverified_individual_student_user.email_verification_code)
      expect(page).to have_content 'Verification Complete'
    end

    scenario 'with an invalid verification code', js: false do
      visit user_verification_path(email_verification_code: 'xyx191')
      expect(page).to have_content I18n.t('controllers.user_activations.update.error')
    end

  end

  describe 'after admin creation visit user_verification url' do
    scenario 'with a password change required', js: false do
      new_pw = '123123123'
      visit user_verification_path(email_verification_code: unverified_comp_user.email_verification_code)
      expect(page).to have_content I18n.t('views.user_password_resets.set_password.h1')
      fill_in I18n.t('views.users.form.password'), with: new_pw
      fill_in I18n.t('views.users.form.password_confirmation'), with: new_pw
      click_button I18n.t('views.general.save')
      sign_out
      sleep(1)
      visit sign_in_path
      within('#sign-in') do
        fill_in I18n.t('views.user_sessions.form.email'), with: unverified_comp_user.email
        fill_in I18n.t('views.user_sessions.form.password'), with: new_pw
        click_button I18n.t('views.general.sign_in')
      end

    end

  end

end
