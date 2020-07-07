# frozen_string_literal: true

require 'rails_helper'

describe 'Password reset process', type: :feature do
  let(:user) { create(:student_user) }

  before :each do
    visit sign_in_path
  end

  context 'User can start the reset process' do
    scenario 'User can start the reset process' do
      click_link('Forgot password?')

      expect(page).to have_content('Enter your email address below to reset your password.')
    end

    scenario 'User can request a password reset email' do
      click_link('Forgot password?')
      fill_in '#email-field', with: user.email
      click_button 'Reset My Password'

      expect(page).to have_content('Check Your Email')
    end
  end

  context 'with a password reset link' do
    let(:user) { create(:student_user, :with_group, password_reset_token: 'A1234567890123456789', password_reset_requested_at: (Time.zone.now - 1.hour)) }

    before :each do
      activate_authlogic
    end

    scenario 'a user can reset their password' do
      visit reset_password_path(id: user.password_reset_token)
      fill_in I18n.t('views.users.form.password'), with: 'newPassw0rd'
      fill_in I18n.t('views.users.form.password_confirmation'), with: 'newPassw0rd'
      click_button I18n.t('views.user_passwords.new.submit')

      expect(page).to have_content I18n.t('controllers.user_passwords.update.flash.success')
      expect(page).to have_current_path(student_dashboard_path)
    end

    scenario 'invalid password data raises an error' do
      visit reset_password_path(id: user.password_reset_token)
      fill_in I18n.t('views.users.form.password'), with: 'newPassw0rd'
      fill_in I18n.t('views.users.form.password_confirmation'), with: 'notMatchingPassword'
      click_button I18n.t('views.user_passwords.new.submit')

      expect(page).to have_content I18n.t('controllers.user_passwords.update.flash.password_and_confirmation_do_not_match')
    end

    context 'with a bad reset token' do
      scenario 'the user is redirected to the sign in page' do
        visit reset_password_path(id: 'badToken')

        expect(page).to have_content I18n.t('controllers.user_passwords.edit.flash.warning')
        expect(page).to have_current_path(sign_in_path)
      end
    end
  end
end
