require 'rails_helper'
require 'support/users_and_groups_setup'
require 'support/subscription_plans_setup'
require 'support/course_content'

describe 'Course content Vs Paywall', type: :feature do

  include_context 'users_and_groups_setup'
  include_context 'subscription_plans_setup'
  include_context 'course_content'

  after { StripeMock.stop }

  describe 'Anonymous user' do
    scenario 'can see free content and cannot see protected content', js: true do
      expect(individual_student_user_group.id).to be > 0
      visit library_path
      click_link('ACA1')
      click_link('Start')
      expect(page).to have_content(course_module_1.name)
      expect(page).to have_css('.quiz-well')
      click_link(course_module_element_1_3.name)
      expect(page).to have_content I18n.t('views.courses.content_denied.not_logged_in.h2')
    end
  end

  describe 'signed in as a student student' do
    before(:each) do
      activate_authlogic
      visit root_path
      click_link I18n.t('views.general.sign_up')
      expect(page).to have_content maybe_upcase I18n.t('views.student_sign_ups.new.h1')
      student_sign_up_as('Dan', 'Murphy', nil, 'valid', eur, ireland, 1, true)
      visit library_path
      click_link institution_1.short_name
      click_link I18n.t('views.general.start')
      expect(page).to have_content course_module_1.name
    end

    scenario 'should see all content', js: true do
      expect(page).to have_css('.quiz-well')
      click_link course_module_element_1_3.name
      expect(page).not_to have_content I18n.t('views.courses.content_denied.not_logged_in.h2')
      expect(page).not_to have_content I18n.t('views.courses.content_denied.account_problem.h2')
      expect(page).to have_content I18n.t('views.course_module_elements.show.next_step')
      expect(page).to have_css('.glyphicon-chevron-right')
    end

    scenario 'should only see free content with a cancelled account', js: true do
      visit profile_path
      click_link I18n.t('views.users.show.tabs.subscriptions')
      click_link I18n.t('views.users.show.cancel_your_subscription_plan')
      page.driver.browser.switch_to.alert.accept
      click_link I18n.t('views.users.show.tabs.subscriptions')
      expect(page).to have_content "'canceled'"
      visit library_path
      click_link institution_1.short_name
      click_link I18n.t('views.general.start')
      expect(page).to have_content course_module_1.name
      click_link course_module_element_1_3.name
      expect(page).to have_content course_module_element_1_3.name
      expect(page).to have_content I18n.t('views.courses.content_denied.account_cancelled.h2')
    end

    scenario 'should only see free content with an account problem', js: true do
      Subscription.first.update_column(:current_status, 'unpaid')
      expect(page).to have_content(course_module_element_1_1.name)
      expect(page).to have_content(course_module_element_1_2.name)
      expect(page).to have_content(course_module_element_1_3.name)
      expect(page).to have_css('.quiz-well')
      click_link(course_module_element_1_3.name)
      expect(page).not_to have_content I18n.t('views.courses.content_denied.not_logged_in.h2')
      expect(page).to have_content I18n.t('views.courses.content_denied.account_problem.h2')
    end

  end
end
