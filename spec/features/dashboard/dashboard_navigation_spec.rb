require 'rails_helper'
require 'support/users_and_groups_setup'
require 'support/course_content'
require 'support/subscription_plans_setup'


describe 'User navigating through the dashboard:', type: :feature do

  include_context 'users_and_groups_setup'
  include_context 'course_content'
  include_context 'subscription_plans_setup'


  let!(:static_page) { FactoryGirl.create(:landing_page) }

  before(:each) do
    activate_authlogic
  end

  describe 'navigates to dashboard' do

    scenario 'not logged-in user will be redirected as not allowed', js: true  do
      visit root_path
      click_link 'Courses'
      visit dashboard_path
      expect(page).to have_content 'You must be signed in to access that page - please sign in'
      within('.login-form') do
        expect(page).to have_content 'Email Password Forgot password?'
      end
    end

    scenario 'when logged in as an individual user', js: true do
      sign_up_and_upgrade_from_free_trial
      within('.navbar.navbar-default') do
        click_link 'Dashboard'
      end
      expect(page).to have_content 'Welcome to your Dashboard'
      within('.navbar.navbar-default') do
        click_link 'Courses'
      end
      click_link('Group 1')
      click_link('Subject Course 1')
      parent = page.find('.course-topics-list li:first-child')
      parent.click
      page.find('#collapse_0').click

      expect(page).to have_content course_module_element_1_1.name
      page.all('.quiz-answer-clickable').first.click
      expect(page).to have_content I18n.t('views.courses.show_results.h1')
      within('.navbar.navbar-default') do
        click_link 'Dashboard'
      end
      expect(page).to have_content subject_course_1.name
      expect(page).to have_css('.progress')
      expect(page).to have_css('.card')
      expect(page).to have_content('1 out of 3 lessons completed')
      click_link('Resume Course')
      find('.panel-body').click
      expect(page).to have_content subject_course_1.name
      within('.navbar.navbar-default') do
        click_link 'Dashboard'
      end
      expect(page).to have_content subject_course_1.name
      expect(page).to have_css('.progress')
      expect(page).to have_css('.card')
      sign_out
    end

  end

end
