require 'rails_helper'
require 'support/users_and_groups_setup'

describe 'The sign in process.', type: :feature do

  include_context 'users_and_groups_setup'

  context 'logged in as a individual_user:' do

    before(:each) do
      activate_authlogic
      x = individual_student_user.id
    end

    scenario 'with no details' do
      visit sign_in_path
      within('.sign-in-modal') do
        fill_in I18n.t('views.user_sessions.form.email'), with: ''
        fill_in I18n.t('views.user_sessions.form.password'), with: ''
        click_button I18n.t('views.general.sign_in')
      end
      expect(page).to have_content 'You did not provide any details for authentication.'
      page.has_selector?('form_for')
    end

    scenario 'with bad details' do
      visit sign_in_path
      within('.sign-in-modal') do
        fill_in I18n.t('views.user_sessions.form.email'), with: 'user@work.com'
        fill_in I18n.t('views.user_sessions.form.password'), with: 'abcabcabc'
        click_button I18n.t('views.general.sign_in')
      end
      expect(page).to have_content 'Email is not valid '
      page.has_selector?('form_for')
    end

    scenario 'with no password' do
      visit sign_in_path
      within('.sign-in-modal') do
        fill_in I18n.t('views.user_sessions.form.email'), with: 'user@work.com'
        fill_in I18n.t('views.user_sessions.form.password'), with: ''
        click_button I18n.t('views.general.sign_in')
      end
      expect(page).to have_content 'Password cannot be blank'
      page.has_selector?('form_for')
    end

    scenario 'as a non-active user' do
      visit sign_in_path
      within('.sign-in-modal') do
        fill_in I18n.t('views.user_sessions.form.email'), with: inactive_individual_student_user.email
        fill_in I18n.t('views.user_sessions.form.password'), with: inactive_individual_student_user.password
        click_button I18n.t('views.general.sign_in')
      end
      expect(page).to have_content 'Your account is not active'
    end

    scenario 'with correct details and then sign out' do
      visit sign_in_path
      within('.sign-in-modal') do
        fill_in I18n.t('views.user_sessions.form.email'), with: individual_student_user.email
        fill_in I18n.t('views.user_sessions.form.password'), with: individual_student_user.password
        click_button I18n.t('views.general.sign_in')
      end
      click_on('dropdown.dropdown-toggle')
      click_link('Sign out')
    end

  end

  context 'Logged in as a corporate_student_user:' do

    before(:each) do
      activate_authlogic
      x = corporate_student_user.id
    end

    scenario 'with no details' do
      visit sign_in_path
      within('.sign-in-modal') do
        fill_in I18n.t('views.user_sessions.form.email'), with: ''
        fill_in I18n.t('views.user_sessions.form.password'), with: ''
        click_button I18n.t('views.general.sign_in')
      end
      expect(page).to have_content 'You did not provide any details for authentication.'
      page.has_selector?('form_for')
    end

    scenario 'with bad details' do
      visit sign_in_path
      within('.sign-in-modal') do
        fill_in I18n.t('views.user_sessions.form.email'), with: 'user@work.com'
        fill_in I18n.t('views.user_sessions.form.password'), with: 'abcabcabc'
        click_button I18n.t('views.general.sign_in')
      end
      expect(page).to have_content 'Email is not valid '
      page.has_selector?('form_for')
    end

    scenario 'with no password' do
      visit sign_in_path
      within('.sign-in-modal') do
        fill_in I18n.t('views.user_sessions.form.email'), with: 'user@work.com'
        fill_in I18n.t('views.user_sessions.form.password'), with: ''
        click_button I18n.t('views.general.sign_in')
      end
      expect(page).to have_content 'Password cannot be blank'
      page.has_selector?('form_for')
    end

    #TODO When the corporate_student_user dashboard partial is built this needs to test for it.
    #scenario 'with correct details and then sign out' do
    #  visit sign_in_path
    #  within('.sign-in-modal') do
    #    fill_in I18n.t('views.user_sessions.form.email'), with: corporate_student_user.email
    #    fill_in I18n.t('views.user_sessions.form.password'), with: corporate_student_user.password
    #    click_button I18n.t('views.general.go')
    #  end
    #  expect(page).to have_content 'Welcome back!'
    #  click_link('navbar-cog')
    #  click_link('Sign out')
    #  expect(page).to have_content 'You are now logged out '
    #end

  end

  context 'Logged in as a tutor_user:' do

    before(:each) do
      activate_authlogic
      x = tutor_user.id
    end

    scenario 'with no details' do
      visit sign_in_path
      within('.sign-in-modal') do
        fill_in I18n.t('views.user_sessions.form.email'), with: ''
        fill_in I18n.t('views.user_sessions.form.password'), with: ''
        click_button I18n.t('views.general.sign_in')
      end
      expect(page).to have_content 'You did not provide any details for authentication.'
      page.has_selector?('form_for')
    end

    scenario 'with bad details' do
      visit sign_in_path
      within('.sign-in-modal') do
        fill_in I18n.t('views.user_sessions.form.email'), with: 'user@work.com'
        fill_in I18n.t('views.user_sessions.form.password'), with: 'abcabcabc'
        click_button I18n.t('views.general.sign_in')
      end
      expect(page).to have_content 'Email is not valid '
      page.has_selector?('form_for')
    end

    scenario 'with no password' do
      visit sign_in_path
      within('.sign-in-modal') do
        fill_in I18n.t('views.user_sessions.form.email'), with: 'user@work.com'
        fill_in I18n.t('views.user_sessions.form.password'), with: ''
        click_button I18n.t('views.general.sign_in')
      end
      expect(page).to have_content 'Password cannot be blank'
      page.has_selector?('form_for')
    end

    scenario 'with correct details and then sign out' do
      visit sign_in_path
      within('.sign-in-modal') do
        fill_in I18n.t('views.user_sessions.form.email'), with: tutor_user.email
        fill_in I18n.t('views.user_sessions.form.password'), with: tutor_user.password
        click_button I18n.t('views.general.sign_in')
      end
      expect(page).to have_content 'Welcome back!'
      expect(page).to have_content maybe_upcase I18n.t('views.general.tools')
      click_link(I18n.t('views.general.tools'))
      expect(page).to have_content maybe_upcase I18n.t('views.layouts.navigation.course_content')
      expect(page).to_not have_content I18n.t('views.subject_areas.index.h1')
      click_link('navbar-cog')
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
      within('.sign-in-modal') do
        fill_in I18n.t('views.user_sessions.form.email'), with: ''
        fill_in I18n.t('views.user_sessions.form.password'), with: ''
        click_button I18n.t('views.general.sign_in')
      end
      expect(page).to have_content 'You did not provide any details for authentication.'
      page.has_selector?('form_for')
    end

    scenario 'with bad details' do
      visit sign_in_path
      within('.sign-in-modal') do
        fill_in I18n.t('views.user_sessions.form.email'), with: 'user@work.com'
        fill_in I18n.t('views.user_sessions.form.password'), with: 'abcabcabc'
        click_button I18n.t('views.general.sign_in')
      end
      expect(page).to have_content 'Email is not valid '
      page.has_selector?('form_for')
    end

    scenario 'with no password' do
      visit sign_in_path
      within('.sign-in-modal') do
        fill_in I18n.t('views.user_sessions.form.email'), with: 'user@work.com'
        fill_in I18n.t('views.user_sessions.form.password'), with: ''
        click_button I18n.t('views.general.sign_in')
      end
      expect(page).to have_content 'Password cannot be blank'
      page.has_selector?('form_for')
    end

    scenario 'with correct details and then sign out' do
      visit sign_in_path
      within('.sign-in-modal') do
        fill_in I18n.t('views.user_sessions.form.email'), with: content_manager_user.email
        fill_in I18n.t('views.user_sessions.form.password'), with: content_manager_user.password
        click_button I18n.t('views.general.sign_in')
      end
      expect(page).to have_content 'Welcome back!'
      click_link(I18n.t('views.general.tools'))
      expect(page).to have_content 'Dashboard'
      click_link('navbar-cog')
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
      within('.sign-in-modal') do
        fill_in I18n.t('views.user_sessions.form.email'), with: ''
        fill_in I18n.t('views.user_sessions.form.password'), with: ''
        click_button I18n.t('views.general.sign_in')
      end
      expect(page).to have_content 'You did not provide any details for authentication.'
      page.has_selector?('form_for')
    end

    scenario 'with bad details' do
      visit sign_in_path
      within('.sign-in-modal') do
        fill_in I18n.t('views.user_sessions.form.email'), with: 'user@work.com'
        fill_in I18n.t('views.user_sessions.form.password'), with: 'abcabcabc'
        click_button I18n.t('views.general.sign_in')
      end
      expect(page).to have_content 'Email is not valid '
      page.has_selector?('form_for')
    end

    scenario 'with no password' do
      visit sign_in_path
      within('.sign-in-modal') do
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
    #  within('.sign-in-modal') do
    #    fill_in I18n.t('views.user_sessions.form.email'), with: blogger_user.email
    #    fill_in I18n.t('views.user_sessions.form.password'), with: blogger_user.password
    #    click_button I18n.t('views.general.go')
    #  end
    #  expect(page).to have_content 'Welcome back!'
    #  click_link('navbar-cog')
    #  click_link('Sign out')
    #end

  end

  context 'Logged in as a corporate_customer_user:' do

    before(:each) do
      activate_authlogic
      x = corporate_customer_user.id
    end

    scenario 'with no details' do
      visit sign_in_path
      within('.sign-in-modal') do
        fill_in I18n.t('views.user_sessions.form.email'), with: ''
        fill_in I18n.t('views.user_sessions.form.password'), with: ''
        click_button I18n.t('views.general.sign_in')
      end
      expect(page).to have_content 'You did not provide any details for authentication.'
      page.has_selector?('form_for')
    end

    scenario 'with bad details' do
      visit sign_in_path
      within('.sign-in-modal') do
        fill_in I18n.t('views.user_sessions.form.email'), with: 'user@work.com'
        fill_in I18n.t('views.user_sessions.form.password'), with: 'abcabcabc'
        click_button I18n.t('views.general.sign_in')
      end
      expect(page).to have_content 'Email is not valid '
      page.has_selector?('form_for')
    end

    scenario 'with no password' do
      visit sign_in_path
      within('.sign-in-modal') do
        fill_in I18n.t('views.user_sessions.form.email'), with: 'user@work.com'
        fill_in I18n.t('views.user_sessions.form.password'), with: ''
        click_button I18n.t('views.general.sign_in')
      end
      expect(page).to have_content 'Password cannot be blank'
      page.has_selector?('form_for')
    end

    #TODO When the corporate customer dashboard partial is built this needs to test for it.
    #scenario 'with correct details and then sign out' do
    #  visit sign_in_path
    #  within('.sign-in-modal') do
    #    fill_in I18n.t('views.user_sessions.form.email'), with: corporate_customer_user.email
    #    fill_in I18n.t('views.user_sessions.form.password'), with: corporate_customer_user.password
    #    click_button I18n.t('views.general.go')
    #  end
    #  expect(page).to have_content 'Welcome back!'
    #  click_link('navbar-cog')
    #  click_link('Sign out')
    #end

  end

  context 'Logged in as a forum_manager_user:' do

    before(:each) do
      activate_authlogic
      x = forum_manager_user.id
    end

    scenario 'with no details' do
      visit sign_in_path
      within('.sign-in-modal') do
        fill_in I18n.t('views.user_sessions.form.email'), with: ''
        fill_in I18n.t('views.user_sessions.form.password'), with: ''
        click_button I18n.t('views.general.sign_in')
      end
      expect(page).to have_content 'You did not provide any details for authentication.'
      page.has_selector?('form_for')
    end

    scenario 'with bad details' do
      visit sign_in_path
      within('.sign-in-modal') do
        fill_in I18n.t('views.user_sessions.form.email'), with: 'user@work.com'
        fill_in I18n.t('views.user_sessions.form.password'), with: 'abcabcabc'
        click_button I18n.t('views.general.sign_in')
      end
      expect(page).to have_content 'Email is not valid '
      page.has_selector?('form_for')
    end

    scenario 'with no password' do
      visit sign_in_path
      within('.sign-in-modal') do
        fill_in I18n.t('views.user_sessions.form.email'), with: 'user@work.com'
        fill_in I18n.t('views.user_sessions.form.password'), with: ''
        click_button I18n.t('views.general.sign_in')
      end
      expect(page).to have_content 'Password cannot be blank'
      page.has_selector?('form_for')
    end

    #TODO When the forum manager dashboard partial is built this needs to test for it.
    #scenario 'with correct details and then sign out' do
    #  visit sign_in_path
    #  within('.sign-in-modal') do
    #    fill_in I18n.t('views.user_sessions.form.email'), with: forum_manager_user.email
    #    fill_in I18n.t('views.user_sessions.form.password'), with: forum_manager_user.password
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
      within('.sign-in-modal') do
        fill_in I18n.t('views.user_sessions.form.email'), with: ''
        fill_in I18n.t('views.user_sessions.form.password'), with: ''
        click_button I18n.t('views.general.sign_in')
      end
      expect(page).to have_content 'You did not provide any details for authentication.'
      page.has_selector?('form_for')
    end

    scenario 'with bad details' do
      visit sign_in_path
      within('.sign-in-modal') do
        fill_in I18n.t('views.user_sessions.form.email'), with: 'user@work.com'
        fill_in I18n.t('views.user_sessions.form.password'), with: 'abcabcabc'
        click_button I18n.t('views.general.sign_in')
      end
      expect(page).to have_content 'Email is not valid '
      page.has_selector?('form_for')
    end

    scenario 'with no password' do
      visit sign_in_path
      within('.sign-in-modal') do
        fill_in I18n.t('views.user_sessions.form.email'), with: 'user@work.com'
        fill_in I18n.t('views.user_sessions.form.password'), with: ''
        click_button I18n.t('views.general.sign_in')
      end
      expect(page).to have_content 'Password cannot be blank'
      page.has_selector?('form_for')
    end

    scenario 'with correct details and then sign out' do
      visit sign_in_path
      within('.sign-in-modal') do
        fill_in I18n.t('views.user_sessions.form.email'), with: admin_user.email
        fill_in I18n.t('views.user_sessions.form.password'), with: admin_user.password
        click_button I18n.t('views.general.sign_in')
      end
      expect(page).to have_content 'Welcome back!'
      expect(page).to have_content 'Dashboard: '
      expect(page).to have_content I18n.t('views.general.tools')
      click_link(I18n.t('views.general.tools'))
      expect(page).to have_content I18n.t('views.dashboard.admin.subject_areas')
      click_link('navbar-cog')
      click_link('Sign out')
    end

  end

end
