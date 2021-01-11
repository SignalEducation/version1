# frozen_string_literal: true

require 'rails_helper'
require 'support/course_content'

describe 'Notes Course Step', type: :feature do
  include_context 'course_content'

  let(:user_group)    { create(:student_user_group) }
  let(:student)       { create(:basic_student, :with_group, user_group: user_group) }
  let!(:course_log)   { create(:course_log, course: course_1, user: student) }

  before :each do
    activate_authlogic
    sign_in_via_sign_in_page(student)
  end

  context 'User course lesson' do
    scenario 'Loading not permitted access' do
      visit show_course_path(course_name_url: course_note.course_step.course_lesson.course.name_url,
                             course_section_name_url: course_note.course_step.course_lesson.course_section.name_url,
                             course_lesson_name_url: course_note.course_step.name_url)

      expect(page).to have_content(course_note.course_step.course_lesson.name)
      expect(page).to have_content(course_note.course_step.course_lesson.course.name)
      expect(page).to have_content('Sorry, you are not permitted to access that content.')
    end

    scenario 'Loading notes page' do
      allow_any_instance_of(CourseStep).to receive(:available_to_user).and_return(view: true, reason: nil)

      visit show_course_path(course_name_url: course_note.course_step.course_lesson.course.name_url,
                             course_section_name_url: course_note.course_step.course_lesson.course_section.name_url,
                             course_lesson_name_url: course_note.course_step.course_lesson.name_url,
                             course_step_name_url: course_note.course_step.name_url)

      expect(page).to have_title('The Smarter Way to Study | learnsignal')
    end
  end
end
