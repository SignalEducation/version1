require 'rails_helper'
require 'support/users_and_groups_setup'
require 'support/subscription_plans_setup'
require 'support/course_content'

describe 'Course content Vs Paywall', type: :feature do

  include_context 'users_and_groups_setup'
  include_context 'subscription_plans_setup'
  include_context 'course_content'

  after { StripeMock.stop }

  before(:each) do
    activate_authlogic
  end

  describe 'Anonymous user' do
    scenario 'cannot see any content', js: true do
      expect(individual_student_user_group.id).to be > 0
      visit library_path
      click_link('Group 1')
      click_link('Subject Course 1')
      #Todo select the first CM and click the first CME inside the panel; expect to see the sign-up modal
    end
  end

  #Todo select the first CM and click the first CME inside the panel; expect to see the sign-up modal
  xit describe 'sign up and upgrade to paying plan as a normal student' do
    before(:each) do
      activate_authlogic
      sign_up_and_upgrade_from_free_trial
      click_link 'Courses'
      click_link('Group 1')
      click_link('Subject Course 1')
      click_link('Start Course')
      expect(page).to have_content(course_module_1.name)
    end

    scenario 'should see all content', js: true do
      expect(page).to have_css('#quiz-contents')
      click_link course_module_element_1_3.name
      expect(page).to have_content(course_module_element_1_3.name)
      expect(page).to have_content(course_module_1.name)
      expect(page).to have_css('#quiz-contents')
    end

    scenario 'should still see all content with a recently cancelled account', js: true do
      visit_my_profile
      click_on 'Subscriptions'
      click_link I18n.t('views.users.show.cancel_your_subscription_plan')
      page.driver.browser.switch_to.alert.accept
      click_on 'Subscriptions'
      expect(page).to have_content 'Undo Your Account Cancellation'
      click_link 'Courses'
      click_link('Group 1')
      click_link('Subject Course 1')
      click_link('Start Course')
      expect(page).to have_content course_module_1.name
      expect(page).to have_css('#quiz-contents')
      click_link course_module_element_1_3.name
      expect(page).to have_content course_module_element_1_3.name
    end

    scenario 'should only see free content with an account problem', js: true do
      Subscription.last.update_column(:current_status, 'unpaid')
      expect(page).to have_content(course_module_element_1_1.name)
      expect(page).to have_content(course_module_element_1_2.name)
      expect(page).to have_content(course_module_element_1_3.name)
      expect(page).to have_css('#quiz-contents')
      click_link(course_module_element_1_3.name)
      expect(page).not_to have_content I18n.t('views.courses.content_denied.not_logged_in.h2')
      expect(page).to have_content I18n.t('views.courses.content_denied.account_problem.h2')
    end

  end
end
