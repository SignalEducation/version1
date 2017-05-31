require 'rails_helper'
require 'support/users_and_groups_setup'
require 'support/subscription_plans_setup'
require 'support/course_content'
require 'support/system_setup'

describe 'Course content Vs Paywall', type: :feature do

  include_context 'users_and_groups_setup'
  include_context 'subscription_plans_setup'
  include_context 'course_content'
  include_context 'system_setup'

  after { StripeMock.stop }

  before(:each) do
    activate_authlogic
  end

  describe 'Anonymous user' do
    scenario 'cannot see any content', js: true do
      expect(individual_student_user_group.id).to be > 0
      visit home_path
      click_on('Courses')
      click_link('Group 1')
      click_link('Subject Course 1')
      parent = page.find('.course-topics-list li:first-child')
      parent.click
      sleep(1)
      click_on(course_module_element_1_1.name)
      sleep(1)
      expect(page).to have_content('Start Free 7-Day Trial')
    end
  end

  describe 'sign up and upgrade to paying plan as a normal student' do
    before(:each) do
      activate_authlogic
      sign_up_and_upgrade_from_free_trial
      click_link 'Courses'
      click_link('Group 1')
      click_link('Subject Course 1')
      parent = page.find('.course-topics-list li:first-child')
      parent.click
      sleep(1)
    end

    scenario 'should see all content', js: true do
      click_on(course_module_element_1_1.name)
      expect(page).to have_content(course_module_element_1_1.name)

    end

    scenario 'should still see all content with a cancelled pending account', js: true do
      visit_my_profile
      sleep(2)
      click_on I18n.t('views.users.show.tabs.subscriptions')
      expect(page).to have_content 'Account Status Active Subscription'
      expect(page).to have_content 'Billing Interval Monthly'
      click_link I18n.t('views.users.show.cancel_your_subscription_plan')
      page.driver.browser.switch_to.alert.accept
      click_on I18n.t('views.users.show.tabs.subscriptions')
      click_link 'Courses'
      click_link('Group 1')
      click_link('Subject Course 1')
      parent = page.find('.course-topics-list li:first-child')
      parent.click
      sleep(1)
      click_on(course_module_element_1_1.name)

    end

    scenario 'should still see content with a failed payment', js: true do
      sleep(10)
      Subscription.last.update_column(:current_status, 'past_due')
      expect(page).to have_content(course_module_element_1_1.name)
    end

    scenario 'should only see free content with an account problem', js: true do
      User.last.update_column(:trial_limit_in_seconds, '12001')
      expect(page).to have_content(course_module_element_1_1.name)
      click_link(course_module_element_1_3.name)
    end

  end
end
