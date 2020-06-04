# frozen_string_literal: true

require 'rails_helper'
require 'support/course_content'

describe 'Video Quiz Step', type: :feature do
  include_context 'course_content'

  let(:user_group)    { create(:student_user_group) }
  let(:student)       { create(:basic_student, :with_group, user_group: user_group) }

  before :each do
    activate_authlogic
    sign_in_via_sign_in_page(student)
  end

  context 'User course lesson' do
    scenario 'Loading not permitted access' do
      visit show_course_path(course_name_url: course_quiz.course_step.course_lesson.course.name_url,
                             course_section_name_url: course_quiz.course_step.course_lesson.course_section.name_url,
                             course_lesson_name_url: course_quiz.course_step.name_url)

      expect(page).to have_content(course_quiz.course_step.course_lesson.name)
      expect(page).to have_content(course_quiz.course_step.course_lesson.course.name)
      expect(page).to have_content('Sorry, you are not permitted to access that content.')
    end

    scenario 'Loading quiz and answer correctly a question', js: true do
      allow_any_instance_of(CourseStep).to receive(:available_to_user).and_return(view: true, reason: nil)

      visit show_course_path(course_name_url: course_quiz.course_step.course_lesson.course.name_url,
                             course_section_name_url: course_quiz.course_step.course_lesson.course_section.name_url,
                             course_lesson_name_url: course_quiz.course_step.course_lesson.name_url,
                             course_step_name_url: course_quiz.course_step.name_url)

      expect(page).to have_title('The Smarter Way to Study | learnsignal')
      expect(page).to have_content("Question 1 of #{course_quiz.number_of_questions}")
      expect(page).to have_content(course_quiz.course_step.name)
      expect(page).to have_content(course_quiz.quiz_questions.first.quiz_contents.sample.text_content)
      sleep(3)
      expect(page).to have_css('div#answer_1')

      find('#answer_1').click

      expect(page).to have_content('Pass')
      expect(page).to have_selector(:link_or_button, I18n.t('views.course_steps.show.next_step'))
    end

    scenario 'Loading quiz and answer incorrectly a question', js: true do
      allow_any_instance_of(CourseStep).to receive(:available_to_user).and_return(view: true, reason: nil)

      visit show_course_path(course_name_url: course_quiz.course_step.course_lesson.course.name_url,
                             course_section_name_url: course_quiz.course_step.course_lesson.course_section.name_url,
                             course_lesson_name_url: course_quiz.course_step.course_lesson.name_url,
                             course_step_name_url: course_quiz.course_step.name_url)

      expect(page).to have_title('The Smarter Way to Study | learnsignal')
      expect(page).to have_content("Question 1 of #{course_quiz.number_of_questions}")
      expect(page).to have_content(course_quiz.course_step.name)
      expect(page).to have_content(course_quiz.quiz_questions.first.quiz_contents.sample.text_content)
      sleep(3)
      expect(page).to have_css('div#answer_3')

      find('#answer_3').click

      expect(page).to have_content('Fail')
      expect(page).to have_selector(:link_or_button, I18n.t('views.course_steps.show.next_step'))
    end
  end
end
