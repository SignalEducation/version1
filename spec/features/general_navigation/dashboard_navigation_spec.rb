require 'rails_helper'
require 'support/users_and_groups_setup'
require 'support/course_content'

require 'support/system_setup'


describe 'User navigating through the dashboard:', type: :feature do

  include_context 'users_and_groups_setup'
  include_context 'course_content'

  include_context 'system_setup'


  before(:each) do
    activate_authlogic
  end

  describe 'student user logs in and enrols in a course ' do

    scenario 'completes a quiz and navigates to dashboard', js: true do
      sign_in_via_sign_in_page(student_user)
      within('.navbar.navbar-default') do
        click_link 'Dashboard'
      end
      expect(page).to have_content 'Dashboard'
      within('.navbar.navbar-default') do
        click_link 'Courses'
      end
      click_link('Group 1')
      click_link('Subject Course 1')

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
      sleep(1)
      page.all('.quiz-answer-clickable').first.click

      expect(page).to have_content 'Result:'
      within('.navbar.navbar-default') do
        click_link 'Dashboard'
      end

      expect(page).to have_content subject_course_1.name
      expect(page).to have_css('.card')
      click_link('Resume Course')
      expect(page).to have_content subject_course_1.name
      sign_out
    end

  end

end
