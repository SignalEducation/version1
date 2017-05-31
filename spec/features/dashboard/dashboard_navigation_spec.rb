require 'rails_helper'
require 'support/users_and_groups_setup'
require 'support/course_content'
require 'support/subscription_plans_setup'
require 'support/system_setup'


describe 'User navigating through the dashboard:', type: :feature do

  include_context 'users_and_groups_setup'
  include_context 'course_content'
  include_context 'subscription_plans_setup'
  include_context 'system_setup'


  before(:each) do
    activate_authlogic
  end

  describe 'navigates to dashboard' do

    scenario 'when logged in as an individual user', js: true do
      sign_up_and_upgrade_from_free_trial
      within('.navbar.navbar-default') do
        click_link 'Dashboard'
      end
      expect(page).to have_content 'Dashboard'
      within('.navbar.navbar-default') do
        click_link 'Courses'
      end
      click_link('Group 1')
      click_link('Subject Course 1')
      parent = page.find('.course-topics-list li:first-child')
      parent.click
      click_on(course_module_element_1_1.name)
      expect(page).to have_content course_module_element_1_1.name
      page.all('.quiz-answer-clickable').first.click
      expect(page).to have_content 'Result:'
      within('.navbar.navbar-default') do
        click_link 'Dashboard'
      end
      click_link 'Activity'
      expect(page).to have_content subject_course_1.name
      expect(page).to have_css('.progress')
      expect(page).to have_css('.card')
      click_link('Resume Course')
      expect(page).to have_content subject_course_1.name
      sign_out
    end

  end

end
