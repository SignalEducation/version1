# frozen_string_literal: true

require 'rails_helper'
require 'support/free_lesson_content'

RSpec.describe 'Enrolment', type: :feature do
  include_context 'free_lesson_content'

  describe 'Studant can register they enrolment data' do
    let!(:user_group) { create(:student_user_group) }
    let!(:student)    { create(:active_student_user, preferred_exam_body: exam_body, user_group: user_group) }

    before do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(student)
      allow_any_instance_of(ApplicationController).to receive(:logged_in_required).and_return(true)
      allow_any_instance_of(ApplicationController).to receive(:ensure_user_has_access_rights).and_return(true)

      visit library_course_path(group_name_url: course_1.parent.name_url, course_name_url: course_1.name_url)
    end

    scenario 'Open enrolment modal', js: true do
      expect(page).to have_content('Enrol')
      expect(page).to have_content(course_1.name)
      expect(page).to have_content(course_1.description)
      click_link 'Enrol'

      # Enrol Modal
      expect(page).to have_content("#{course_1.name} Enrolment")
      expect(page).to have_content('Step 1 - Exam Sitting Details')
      expect(page).to have_content('Step 2 - Exam Body Details')
    end

    scenario 'Submit enrolment data', js: true do
      expect(page).to have_content('Enrol')
      expect(page).to have_content(course_1.name)
      expect(page).to have_content(course_1.description)

      click_link 'Enrol'

      # Enrol Modal
      select exam_sitting_1.formatted_date, from: 'exam_sitting_select'

      click_button 'Next Step'

      fill_in 'user_exam_body_user_details_attributes_0_student_number', with: Faker::Number.number(digits: 6)

      click_button 'Complete Enrolment'

      expect(page).to have_content(course_1.name)
    end
  end

  describe 'Studant check the enrolment data in account page' do
    let(:user_group)  { create(:student_user_group) }
    let(:student)     { create(:active_student_user, preferred_exam_body: exam_body, user_group: user_group) }
    let(:log)         { create(:course_log, user: student, course: course_1) }
    let!(:enrollment) { create(:enrollment, user: student, course_log: log, exam_body: exam_body, active: true) }

    before do
      allow_any_instance_of(ApplicationController).to receive(:current_user).and_return(student)
      allow_any_instance_of(ApplicationController).to receive(:logged_in_required).and_return(true)
      allow_any_instance_of(ApplicationController).to receive(:ensure_user_has_access_rights).and_return(true)

      visit account_path
    end

    scenario 'Open enrolment modal', js: true do
      click_link 'Enrolments'

      expect(page).to have_content('Enrolments')
      expect(page).to have_content(enrollment.course.name)

      click_link 'Edit Details'

      expect(page).to have_content('Change Sitting')

      select exam_sitting_2.formatted_date, from: 'exam_sitting_select'

      click_button 'Save Changes'

      expect(page).to have_content('Enrolments')
      expect(page).to have_content(course_1.name)
    end
  end
end
