require 'rails_helper'

shared_context 'free_lesson_content' do
  let!(:exam_body)  { create(:exam_body) }
  let!(:group)      { create(:group, exam_body: exam_body) }
  let!(:level_1)    { create(:level, active: true, group_id: group.id) }
  let!(:course_1)   { create(:active_course, exam_body_id: exam_body.id, group_id: group.id, level_id: level_1.id) }

  # Course Section
  let!(:course_section_1) { create(:course_section, course: course_1) }

  # Course Lesson 1
  let!(:course_lesson_1) { create(:free_course_lesson, course_section: course_section_1, course: course_1) }

  # Course Steps
  # Video 1
  let!(:course_step_1)  { create(:course_step, :video_step, course_lesson: course_lesson_1, sorting_order: 1) }
  let!(:course_video_1) { create(:course_video, course_step_id: course_step_1.id, vimeo_guid: 'abc123', dacast_id: 1234) }

  # Video 2
  let!(:course_step_2)  { create(:course_step, :video_step, course_lesson: course_lesson_1, sorting_order: 2) }
  let!(:course_video_2) { create(:course_video, course_step_id: course_step_2.id, vimeo_guid: 'abc123', dacast_id: 1234) }

  # Quiz
  let!(:course_step_3) { create(:course_step, :quiz_step, course_lesson: course_lesson_1, sorting_order: 3) }
  let!(:course_quiz)   { create(:course_quiz, course_step_id: course_step_3.id, question_selection_strategy: 'ordered') }

  # Notes
  let!(:course_step_4)  { create(:course_step, :notes_step, course_lesson: course_lesson_1, sorting_order: 4) }
  let!(:course_note)    { create(:course_note, :file_uploaded, course_step_id: course_step_4.id) }

  # Video 3 - Exit Video
  let!(:course_step_5)  { create(:course_step, :video_step, course_lesson: course_lesson_1, sorting_order: 5) }
  let!(:course_video_3) { create(:course_video, course_step_id: course_step_5.id, vimeo_guid: 'abc123', dacast_id: 1234) }


  let!(:quiz_question_1) { create(:quiz_question, course_step_id: course_step_3.id, course_quiz_id: course_quiz.id, course_id: course_1.id, sorting_order: 1) }
  let!(:quiz_answer_1)   { create(:correct_quiz_answer, quiz_question: quiz_question_1) }
  let!(:quiz_answer_2)   { create(:correct_quiz_answer, quiz_question: quiz_question_1) }
  let!(:quiz_answer_3)   { create(:quiz_answer, quiz_question: quiz_question_1) }
  let!(:quiz_answer_4)   { create(:quiz_answer, quiz_question: quiz_question_1) }
  let!(:quiz_content_1)  { create(:quiz_content, quiz_question: quiz_question_1) }
  let!(:quiz_content_2)  { create(:quiz_content, quiz_answer: quiz_answer_1) }
  let!(:quiz_content_3)  { create(:quiz_content, quiz_answer: quiz_answer_2) }
  let!(:quiz_content_4)  { create(:quiz_content, quiz_answer: quiz_answer_3) }
  let!(:quiz_content_5)  { create(:quiz_content,quiz_answer: quiz_answer_4) }

  let!(:quiz_question_2)   { create(:quiz_question, course_step_id: course_step_3.id, course_quiz_id: course_quiz.id, course_id: course_1.id, sorting_order: 2) }
  let!(:quiz_answer_2_4)   { create(:quiz_answer, quiz_question: quiz_question_2) }
  let!(:quiz_answer_2_1)   { create(:correct_quiz_answer, quiz_question: quiz_question_2) }
  let!(:quiz_answer_2_2)   { create(:correct_quiz_answer, quiz_question: quiz_question_2) }
  let!(:quiz_answer_2_3)   { create(:quiz_answer, quiz_question: quiz_question_2) }
  let!(:quiz_content_2_5)  { create(:quiz_content, quiz_answer: quiz_answer_4) }
  let!(:quiz_content_2_1a) { create(:quiz_content, quiz_question: quiz_question_1) }
  let!(:quiz_content_2_1b) { create(:quiz_content, quiz_question: quiz_question_1) }
  let!(:quiz_content_2_2)  { create(:quiz_content, quiz_answer: quiz_answer_2) }
  let!(:quiz_content_2_3)  { create(:quiz_content, quiz_answer: quiz_answer_2) }
  let!(:quiz_content_2_4)  { create(:quiz_content, quiz_answer: quiz_answer_3) }

end
