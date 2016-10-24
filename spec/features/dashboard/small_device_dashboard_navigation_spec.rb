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
    page.driver.browser.manage.window.resize_to(300,800)
  end

  after(:each) do
    page.driver.browser.manage.window.resize_to(1024,768)
  end

  describe 'navigates to first cmes' do

    xit scenario 'when logged in as an individual user', js: true do
      visit root_path
      sign_up_and_upgrade_from_free_trial_small_device
      visit dashboard_path
      expect(page).to have_content 'Welcome to your Dashboard'
      expect(page).to have_content 'Please select one of the courses below to get started!'
      within('.navbar.navbar-default') do
        find('.navbar-toggle').click
        click_link 'Courses'
      end
      sleep(1)
      click_link('Group 1')
      click_link('Subject Course 1')

      parent = page.find('.course-topics-list li:first-child')
      parent.click
      page.find('#collapse_0').click

      expect(page).to have_content course_module_element_1_1.name
      page.all('.quiz-answer-clickable').first.click
      expect(page).to have_content I18n.t('views.courses.show_results.h1')
      visit dashboard_path
      expect(page).to have_content subject_course_1.name
      expect(page).to have_css('.progress')
      expect(page).to have_css('.panel')
      within('.panel-body') do
        expect(page).to have_content('1 out of 3 lessons completed')
      end
      find('.panel-body').click
      expect(page).to have_content subject_course_1.name
      visit dashboard_path
      expect(page).to have_content subject_course_1.name
      expect(page).to have_css('.progress')
      expect(page).to have_css('.panel')
    end

  end

end
