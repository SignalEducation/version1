require 'rails_helper'
require 'support/system_setup'
require 'support/users_and_groups_setup'
require 'support/course_content'

describe 'Course content Vs Paywall', type: :feature do

  include_context 'system_setup'
  include_context 'users_and_groups_setup'
  include_context 'course_content'


  describe 'Anonymous user' do
    scenario 'cannot see any content', js: true do
      visit home_path
      click_on('Courses')
      click_link('Group 1')
      click_link('Subject Course 1')
      parent = page.find('.course-topics-list li:first-child')
      parent.click
      click_on(course_module_element_1_1.name)
      expect(page).to have_content('Welcome to your 7-day Free Trial')
    end
  end

  describe 'sign in as' do
    before(:each) do
      activate_authlogic
    end

    scenario 'a valid trial student - can see content', js: true do
      sign_in_via_sign_in_page(valid_trial_student)
      click_link 'Courses'
      click_link(group_1.name)
      sleep(1)
      click_link(subject_course_1.name)
      expect(page).to have_content(subject_course_1.name)
      page.find('#enrol-now-button').click
      within('#enrollment_form') do
        find('#exam_sitting_select').find(:xpath, 'option[2]').select_option
        page.find('#enroll_submit_button').click
      end
      expect(page).to have_content(I18n.t('controllers.enrollments.create.flash.success'))
      parent = page.find('.course-topics-list li:first-child')
      parent.click
      click_on(course_module_element_1_1.name)
      expect(page).to have_content course_module_element_1_1.name
      visit_my_profile
      click_on I18n.t('views.user_accounts.trial_info.tab_heading')
      sleep(1)
      expect(page).to have_content 'Valid Trial'
    end

    scenario 'an expired trial student - cannot see content', js: true do
      sign_in_via_sign_in_page(invalid_trial_student)
      click_link 'Courses'
      click_link(group_1.name)
      sleep(1)
      click_link(subject_course_1.name)
      expect(page).to have_content(subject_course_1.name)
      page.find('#enrol-now-button').click
      within('#enrollment_form') do
        find('#exam_sitting_select').find(:xpath, 'option[2]').select_option
        page.find('#enroll_submit_button').click
      end
      expect(page).to have_content(I18n.t('controllers.enrollments.create.flash.success'))
      parent = page.find('.course-topics-list li:first-child')
      parent.click
      click_on(course_module_element_1_1.name)
      expect(page).to have_content 'Your Free Trial has expired. You need a Valid Subscription to access this content.'
      within('.remodal') do
        click_on 'Upgrade Account'
      end
      expect(page).to have_content I18n.t('views.subscriptions.new_subscription.h1')
      visit_my_profile
      click_on I18n.t('views.user_accounts.trial_info.tab_heading')
      expect(page).to have_content 'Expired Trial'
    end

    scenario 'a valid subscription student - can see content', js: true do
      sign_in_via_sign_in_page(valid_subscription_student)
      click_link 'Courses'
      click_link(group_1.name)
      sleep(1)
      click_link(subject_course_1.name)
      expect(page).to have_content(subject_course_1.name)
      page.find('#enrol-now-button').click
      within('#enrollment_form') do
        find('#exam_sitting_select').find(:xpath, 'option[2]').select_option
        page.find('#enroll_submit_button').click
      end
      expect(page).to have_content(I18n.t('controllers.enrollments.create.flash.success'))
      parent = page.find('.course-topics-list li:first-child')
      parent.click
      click_on(course_module_element_1_1.name)
      expect(page).to have_content course_module_element_1_1.name
      visit_my_profile
      click_on I18n.t('views.user_accounts.subscription_info.tab_heading')
      sleep(1)
      expect(page).to have_content 'Active Subscription'
    end

    scenario 'an invalid subscription student - cannot see content', js: true do
      sign_in_via_sign_in_page(invalid_subscription_student)
      click_link 'Courses'
      click_link(group_1.name)
      sleep(1)
      click_link(subject_course_1.name)
      expect(page).to have_content(subject_course_1.name)
      page.find('#enrol-now-button').click
      within('#enrollment_form') do
        find('#exam_sitting_select').find(:xpath, 'option[2]').select_option
        page.find('#enroll_submit_button').click
      end
      expect(page).to have_content(I18n.t('controllers.enrollments.create.flash.success'))
      parent = page.find('.course-topics-list li:first-child')
      parent.click
      click_on(course_module_element_1_1.name)
      expect(page).to have_content 'Sorry! Your Account is Canceled'
      within('.remodal') do
        click_on I18n.t('views.users.show.reactivate_subscription.button_call_to_action')
      end
      expect(page).to have_content I18n.t('views.subscriptions.new_subscription.h2e')
      visit_my_profile
      click_on I18n.t('views.user_accounts.subscription_info.tab_heading')
      expect(page).to have_content 'Canceled Subscription'
    end

  end
end
