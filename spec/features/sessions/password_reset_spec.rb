require 'rails_helper'
require 'support/users_and_groups_setup'

describe 'The password reset process,', type: :feature do

  include_context 'users_and_groups_setup'

    before(:each) do
      activate_authlogic
      x = individual_student_user.id
    end

    scenario 'attempt to log in then reset password' do
      visit sign_in_path
      within('.login-form') do
        fill_in I18n.t('views.user_sessions.form.email'), with: individual_student_user.email
        fill_in I18n.t('views.user_sessions.form.password'), with: 'abc'
        click_button I18n.t('views.general.sign_in')
      end
      expect(page).to have_content 'Password is not valid'
      click_link('#forgot-password')
      page.has_css?('.page-header', text: I18n.t('views.user_sessions.form.forgot_password'))
      page.has_css?('.forgot-password-modal', text: I18n.t('views.user_password_resets.new.paragraph_1'))
      within('.forgot-password-modal') do
        fill_in ('#email-field'), with: 'user@example.com'
        click_button 'SEND MY PASSWORD'
      end
      expect(page).to have_content('Reset password')
    end

    scenario 'attempt to log in and then reset password', js: true do
      visit student_dashboard_path
      visit sign_in_path
      within('.login-form') do
        fill_in 'user_session_email' , with: individual_student_user.email
        fill_in 'user_session_password', with: 'abc'
        click_button I18n.t('views.general.sign_in')
      end
      expect(page).to have_content 'Password is not valid'
      click_link(I18n.t('views.user_sessions.form.forgot_password'))
      page.has_css?('.page-header', text: I18n.t('views.user_sessions.form.forgot_password'))
      page.has_css?('.forgot-password-modal', text: I18n.t('views.user_password_resets.new.paragraph_1'))
      within('.forgot-password-modal') do
        fill_in ('#email-field'), with: 'user@example.com'
        click_button 'SEND MY PASSWORD'
      end
      expect(page).to have_content('Reset password')
    end

end
