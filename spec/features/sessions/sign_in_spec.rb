require 'rails_helper'
require 'support/system_setup'
require 'support/users_and_groups_setup'

describe 'The sign in process.', type: :feature do

  include_context 'system_setup'
  include_context 'users_and_groups_setup'

  before(:each) do
    activate_authlogic
  end

  scenario 'Successfully signs in as one of the users', js: true do
    user_list.each do |this_user|
      visit sign_in_path
      within('#sign-in') do
        fill_in I18n.t('views.user_sessions.form.email'), with: this_user.email
        fill_in I18n.t('views.user_sessions.form.password'), with: this_user.password
        click_button I18n.t('views.general.sign_in')
      end
      expect(page).to have_content "Welcome #{this_user.first_name}!"
      expect(page).to have_content 'Dashboard'
      find('.dropdown').click
      click_link('Sign out')
      print '>'
    end
  end


  context 'Fails to sign in ', js: true do

    scenario 'with no details' do
      visit sign_in_path
      within('#sign-in') do
        fill_in I18n.t('views.user_sessions.form.email'), with: ''
        fill_in I18n.t('views.user_sessions.form.password'), with: ''
        click_button I18n.t('views.general.sign_in')
      end
      expect(page).to have_content 'You did not provide any details for authentication.'
      page.has_selector?('form_for')
    end

    scenario 'with incorrect details' do
      visit sign_in_path
      within('#sign-in') do
        fill_in I18n.t('views.user_sessions.form.email'), with: 'user@work.com'
        fill_in I18n.t('views.user_sessions.form.password'), with: 'abcabcabc'
        click_button I18n.t('views.general.sign_in')
      end
      expect(page).to have_content 'Email is not valid '
      page.has_selector?('form_for')
    end

    scenario 'with no password' do
      visit sign_in_path
      within('#sign-in') do
        fill_in I18n.t('views.user_sessions.form.email'), with: 'user@work.com'
        fill_in I18n.t('views.user_sessions.form.password'), with: ''
        click_button I18n.t('views.general.sign_in')
      end
      expect(page).to have_content 'Password cannot be blank'
      page.has_selector?('form_for')
    end

    scenario 'as a non-verified user' do
      visit sign_in_path
      within('#sign-in') do
        fill_in I18n.t('views.user_sessions.form.email'), with: unverified_student_user.email
        fill_in I18n.t('views.user_sessions.form.password'), with: unverified_student_user.password
        click_button I18n.t('views.general.sign_in')
      end
      expect(page).to have_content 'Sorry, that email is not verified. Please follow the instructions in the verification email we sent. Or contact us for assistance.'
    end


  end

end
