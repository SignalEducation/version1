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
      within('.well.well-sm') do
        fill_in I18n.t('views.user_sessions.form.email'), with: individual_student_user.email
        fill_in I18n.t('views.user_sessions.form.password'), with: 'abc'
        click_button I18n.t('views.general.go')
      end
      expect(page).to have_content 'Password is not valid'
      click_link('#forgot-password')
      page.has_css?('.page-header', text: I18n.t('views.user_sessions.form.forgot_password'))
      page.has_css?('.well.well-sm', text: I18n.t('views.user_password_resets.new.paragraph_1'))
      within('.well.well-sm') do
        fill_in ('#email-field'), with: 'user@example.com'
        click_button I18n.t('views.general.send')
      end
      expect(page).to have_content('Home')
    end

    scenario 'attempt to log in in navbar then reset password' do
      visit dashboard_path
      click_link('nav-login')
      within('#login_form') do
        fill_in '#hidden-email' , with: individual_student_user.email
        fill_in '#hidden-password', with: 'abc'
        click_button I18n.t('views.general.go')
      end
      expect(page).to have_content 'Password is not valid'
      click_link('#nav-login')
      within('#login_form') do
        click_link('#hidden-password-link')
      end
      page.has_css?('.page-header', text: I18n.t('views.user_sessions.form.forgot_password'))
      page.has_css?('.well.well-sm', text: I18n.t('views.user_password_resets.new.paragraph_1'))
      within('.well.well-sm') do
        fill_in ('#email-field'), with: 'user@example.com'
        click_button I18n.t('views.general.send')
      end
      expect(page).to have_content('Home')
    end

end
