require 'rails_helper'
require 'support/users_and_groups_setup'
require 'support/course_content'
require 'support/subscription_plans_setup'

describe 'User navigating through the library:', type: :feature do

  include_context 'users_and_groups_setup'
  include_context 'course_content'
  include_context 'subscription_plans_setup'

  let!(:static_page) { FactoryGirl.create(:landing_page) }

  before(:each) do
    activate_authlogic
  end

  describe 'User navigates down hierarchy to first cme' do

    scenario 'not logged-in user', js: true  do
      visit root_path
      click_link 'Courses'
      expect(page).to have_content maybe_upcase course_group_1.name
      expect(page).to have_content course_group_1.description
      click_link("#{course_group_1.name}")
      expect(page).to have_content subject_course_1.name
      click_link("#{subject_course_1.name}")
      expect(page).to have_content subject_course_1.name
    end

    scenario 'when logged in as one of the users', js: true do
      sign_up_and_upgrade_from_free_trial
      within('.navbar.navbar-default') do
        click_link 'Courses'
      end
      expect(page).to have_content maybe_upcase course_group_1.name
      expect(page).to have_content course_group_1.description
      click_link("#{course_group_1.name}")
      expect(page).to have_content subject_course_1.name
      click_link("#{subject_course_1.name}")
      expect(page).to have_content subject_course_1.name
      click_link('Start Course')
      expect(page).to have_content(course_module_1.name)
      expect(page).to have_content course_module_element_1_1.name
      expect(page).to have_content course_module_element_1_2.name
      expect(page).to have_content course_module_element_1_3.name
      expect(page).to have_css('#quiz-contents')
      sign_out
      print '>'
    end

  end

end
