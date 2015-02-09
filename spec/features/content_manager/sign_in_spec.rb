require 'rails_helper'
require 'support/users_and_groups_setup'

describe 'The sign in page', type: :feature do

  include_context 'users_and_groups_setup'

  before(:each) do
    activate_authlogic
  end

  scenario 'sign in with no details' do
    visit sign_in_path
    within('.well.well-sm') do
      fill_in 'Email', with: ''
      fill_in 'Password', with: ''
      click_button 'Go'
    end
    expect(page).to have_content 'You did not provide any details for authentication.'
    page.has_selector?('form_for')
  end

  scenario 'sign in with bad details' do
    visit sign_in_path
    within('.well.well-sm') do
      fill_in 'Email', with: 'user@work.com'
      fill_in 'Password', with: 'abcabcabc'
      click_button 'Go'
    end
    expect(page).to have_content 'Email is not valid '
    page.has_selector?('form_for')
  end

  scenario 'sign in with no password' do
    visit sign_in_path
    within('.well.well-sm') do
      fill_in 'Email', with: 'user@work.com'
      fill_in 'Password', with: ''
      click_button 'Go'
    end
    expect(page).to have_content 'Password cannot be blank'
    page.has_selector?('form_for')
  end

  scenario 'successful sign in as an content_manager and then sign out' do
    visit sign_in_path
    within('.well.well-sm') do
      fill_in 'Email', with: content_manager_user.email
      fill_in 'Password', with: content_manager_user.password
      click_button 'Go'
    end
    expect(page).to have_content 'Welcome back!'
    click_link('navbar-cog')
    click_link('Sign out')
    expect(page).to have_content 'You are now logged out '
  end

end
