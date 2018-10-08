require 'rails_helper'
require 'support/system_setup'
require 'support/users_and_groups_setup'
require 'support/course_content'

describe 'Enrollment process', type: :feature do

  include_context 'system_setup'
  include_context 'users_and_groups_setup'
  include_context 'course_content'

  before(:each) do
    activate_authlogic
  end

  describe 'sign in as student users' do
    before(:each) do
      activate_authlogic
      sign_in_via_sign_in_page(student_user)
      click_link 'Courses'
      click_link(group_1.name)
      sleep(1)
    end

    scenario 'enrol in standard exam sitting', js: true do
      # Dropdown select
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
    end

    scenario 'enrol in computer-based exam sitting', js: true do
      # DatePicker selection
      click_link(subject_course_2.name)
      expect(page).to have_content(subject_course_2.name)
      page.find('#enrol-now-button').click

      within('#enrollment_form') do
        page.execute_script("$('#exam_date_timepicker').val('21/02/2019')")
        page.find('#exam_date_timepicker').click
        find('#exam_date_timepicker')
        execute_script("$('#exam_date_timepicker').focusout()")
        page.find('#enroll_submit_button').click
      end
      expect(page).to have_content(I18n.t('controllers.enrollments.create.flash.success'))

      parent = page.find('.course-topics-list li:first-child')
      parent.click
      click_on(course_module_element_2_1.name)
      expect(page).to have_content course_module_element_2_1.name
    end

  end
end
