require 'rails_helper'
require 'support/users_and_groups_setup'

describe 'The sign in process', type: :feature do

  include_context 'users_and_groups_setup'

  before(:each) do
    activate_authlogic
  end

  scenario 'with no details' do
    visit sign_in_path
    within('.well.well-sm') do
      fill_in 'Email', with: ''
      fill_in 'Password', with: ''
      click_button 'Go'
    end
    expect(page).to have_content 'You did not provide any details for authentication.'
    page.has_selector?('form_for')
  end

  scenario 'with bad details' do
    visit sign_in_path
    within('.well.well-sm') do
      fill_in 'Email', with: 'user@work.com'
      fill_in 'Password', with: 'abcabcabc'
      click_button 'Go'
    end
    expect(page).to have_content 'Email is not valid '
    page.has_selector?('form_for')
  end

  scenario 'with no password' do
    visit sign_in_path
    within('.well.well-sm') do
      fill_in 'Email', with: 'user@work.com'
      fill_in 'Password', with: ''
      click_button 'Go'
    end
    expect(page).to have_content 'Password cannot be blank'
    page.has_selector?('form_for')
  end

  scenario 'as a non-active user' do
    visit sign_in_path
    within('.well.well-sm') do
      fill_in 'Email', with: inactive_individual_student_user.email
      fill_in 'Password', with: inactive_individual_student_user.password
      click_button 'Go'
    end
    expect(page).to have_content 'Your account is not active'
  end

  scenario 'with correct details and then sign out', js: true do
    visit sign_in_path
    within('.well.well-sm') do
      fill_in 'Email', with: individual_student_user.email
      fill_in 'Password', with: individual_student_user.password
      click_button 'Go'
    end
    expect(page).to have_content 'Welcome back!'
    click_link('navbar-cog')
    click_link('Sign out')
    expect(page).to have_content 'You are now logged out '
  end

end
