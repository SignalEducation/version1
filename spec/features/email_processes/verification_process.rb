require 'rails_helper'
require 'support/system_setup'
require 'support/users_and_groups_setup'

describe 'The email verification process', type: :feature do

  include_context 'system_setup'
  include_context 'users_and_groups_setup'


  before(:each) do
    activate_authlogic
    visit root_path
  end

  describe 'after sign up visit user_verification url' do
    scenario 'with a valid verification code', js: true do

      visit user_verification_path(email_verification_code: unverified_student_user.email_verification_code)
      expect(page).to have_content 'Verification Complete'
    end

    scenario 'with an invalid verification code', js: true do
      visit user_verification_path(email_verification_code: 'xyx191')
      expect(page).to have_content 'Sorry! That link has expired. Please try to sign in or contact us for assistance'
    end

  end

  describe 'after admin creation visit user_verification url' do
    scenario 'with a password change required', js: true do
      new_pw = '123123123'
      visit user_verification_path(email_verification_code: unverified_comp_user.email_verification_code)
      expect(page).to have_content I18n.t('views.user_passwords.set_password.h2')

      fill_in I18n.t('views.users.form.password'), with: new_pw
      fill_in I18n.t('views.users.form.password_confirmation'), with: new_pw
      find('.check.communication_approval').click
      within('.check.terms_and_conditions') do
        find('span').click
      end

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
