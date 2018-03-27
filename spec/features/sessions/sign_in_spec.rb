require 'rails_helper'
require 'support/users_and_groups_setup'

require 'support/system_setup'
require 'support/course_content'

describe 'The sign in process.', type: :feature do

  include_context 'users_and_groups_setup'

  include_context 'system_setup'
  include_context 'course_content'

  before(:each) do
    a = admin_user
    b = individual_student_user
    e = comp_user
    f = content_manager_user
    g = tutor_user
  end

  context 'logged in as a individual_user:' do

    before(:each) do
      activate_authlogic
      x = individual_student_user.id
    end

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

    scenario 'with bad details' do
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
        fill_in I18n.t('views.user_sessions.form.email'), with: unverified_individual_student_user.email
        fill_in I18n.t('views.user_sessions.form.password'), with: unverified_individual_student_user.password
        click_button I18n.t('views.general.sign_in')
      end
      expect(page).to have_content 'The email for that account has not been verified'
    end

    context 'with correct details and then sign out' do
      scenario 'with free_trial user details' do
        visit sign_in_path
        within('#sign-in') do
          fill_in I18n.t('views.user_sessions.form.email'), with: individual_student_user.email
          fill_in I18n.t('views.user_sessions.form.password'), with: individual_student_user.password
          click_button I18n.t('views.general.sign_in')
        end

        find('.dropdown').click
        click_link('Sign out')
      end

      scenario 'with subscription_student user details' do
        visit sign_in_path
        within('#sign-in') do
          fill_in I18n.t('views.user_sessions.form.email'), with: individual_student_user.email
          fill_in I18n.t('views.user_sessions.form.password'), with: individual_student_user.password
          click_button I18n.t('views.general.sign_in')
        end

        find('.dropdown').click
        click_link('Sign out')
      end

    end

  end

  context 'Logged in as a tutor_user:' do

    before(:each) do
      activate_authlogic
      x = tutor_user.id
    end

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

    scenario 'with bad details' do
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

    scenario 'with correct details and then sign out' do
      visit sign_in_path
      within('#sign-in') do
        fill_in I18n.t('views.user_sessions.form.email'), with: tutor_user.email
        fill_in I18n.t('views.user_sessions.form.password'), with: tutor_user.password
        click_button I18n.t('views.general.sign_in')
      end
      find('.dropdown').click
      click_link('Sign out')
    end

  end

  context 'Logged in as a content_manager_user:' do

    before(:each) do
      activate_authlogic
      x = content_manager_user.id
    end

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

    scenario 'with bad details' do
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

    scenario 'with correct details and then sign out' do
      visit sign_in_path
      within('#sign-in') do
        fill_in I18n.t('views.user_sessions.form.email'), with: content_manager_user.email
        fill_in I18n.t('views.user_sessions.form.password'), with: content_manager_user.password
        click_button I18n.t('views.general.sign_in')
      end
      #expect(page).to have_content maybe_upcase 'Learn anytime, anywhere from our library of business-focused courses taught by expert tutors'
      find('.dropdown').click
      click_link('Sign out')
    end

  end

  context 'Logged in as a blogger_user:' do

    before(:each) do
      activate_authlogic
      x = blogger_user.id
    end

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

    scenario 'with bad details' do
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

    #TODO When the blogger dashboard partial is built this needs to test for it.
    #scenario 'with correct details and then sign out' do
    #  visit sign_in_path
    #  within('.login-form') do
    #    fill_in I18n.t('views.user_sessions.form.email'), with: blogger_user.email
    #    fill_in I18n.t('views.user_sessions.form.password'), with: blogger_user.password
    #    click_button I18n.t('views.general.go')
    #  end
    #  expect(page).to have_content 'Welcome back!'
    #  click_link('navbar-cog')
    #  click_link('Sign out')
    #end

  end

  context 'Logged in as a admin_user:' do

    before(:each) do
      activate_authlogic
      x = admin_user.id
    end

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

    scenario 'with bad details' do
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

    scenario 'with correct details and then sign out' do
      visit sign_in_path
      within('#sign-in') do
        fill_in I18n.t('views.user_sessions.form.email'), with: admin_user.email
        fill_in I18n.t('views.user_sessions.form.password'), with: admin_user.password
        click_button I18n.t('views.general.sign_in')
      end
      expect(page).to have_content 'Dashboard'
      expect(page).to have_content 'Admin'
      find('.dropdown.dropdown-admin').click
      expect(page).to have_content I18n.t('views.users.index.h1')
      expect(page).to have_content I18n.t('views.user_groups.index.h1')
      find('.dropdown.dropdown-normal').click
      click_link('Sign out')
    end

  end

end
