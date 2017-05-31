require 'rails_helper'
require 'support/users_and_groups_setup'
require 'support/course_content'
require 'support/subscription_plans_setup'
require 'support/system_setup'

describe 'User navigating through the library:', type: :feature do

  include_context 'users_and_groups_setup'
  include_context 'course_content'
  include_context 'subscription_plans_setup'
  include_context 'system_setup'

  before(:each) do
    activate_authlogic
  end

  describe 'User navigates down hierarchy to first cme' do

    scenario 'not logged-in user', js: true  do
      visit root_path
      visit home_path
      click_on('Courses')
      click_link(course_group_1.name)
      click_link(subject_course_1.name)
      expect(page).to have_content subject_course_1.name
    end

    scenario 'when logged in as one of the users', js: true do
      sign_up_and_upgrade_from_free_trial
      within('.navbar.navbar-default') do
        click_link 'Courses'
      end
      click_link(course_group_1.name)
      click_link(subject_course_1.name)
      expect(page).to have_content subject_course_1.name
      parent = page.find('.course-topics-list li:first-child')
      parent.click
      click_on(course_module_element_1_1.name)
      expect(page).to have_content(course_module_1.name)
      expect(page).to have_content course_module_element_1_1.name
      expect(page).to have_content course_module_element_1_2.name
      expect(page).to have_content course_module_element_1_3.name
      sign_out
      print '>'
    end

  end

end
