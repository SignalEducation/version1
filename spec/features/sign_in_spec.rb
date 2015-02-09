require 'rails_helper'
require 'support/users_and_groups_setup'

describe 'The sign in process', type: :feature do

  include_context 'users_and_groups_setup'

  before(:each) do
    activate_authlogic
  end


  scenario 'with no details', js: true do
    visit sign_in_path
    within('.well.well-sm') do
      fill_in 'Email', with: ''
      fill_in 'Password', with: ''
      click_button 'Go'
    end
    expect(page).to have_content 'You did not provide any details for authentication.'
    page.has_selector?('form_for')
  end

  scenario 'with bad details', js: true  do
    visit sign_in_path
    within('.well.well-sm') do
      fill_in 'Email', with: 'user@work.com'
      fill_in 'Password', with: 'abcabcabc'
      click_button 'Go'
    end
    expect(page).to have_content 'Email is not valid '
    page.has_selector?('form_for')
  end

  scenario 'with bad details', js: true do
    visit sign_in_path
    within('.well.well-sm') do
      fill_in 'Email', with: 'user@work.com'
      fill_in 'Password', with: ''
      click_button 'Go'
    end
    expect(page).to have_content 'Password cannot be blank'
    page.has_selector?('form_for')
  end

  scenario 'as an individual student', js: true do
    visit sign_in_path
    within('.well.well-sm') do
      fill_in 'Email', with: individual_student_user.email
      fill_in 'Password', with: individual_student_user.password
      click_button 'Go'
    end
    expect(page).to have_content 'Welcome back!'
  end

end