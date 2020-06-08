require 'rails_helper'

shared_context 'course_content' do
  let!(:exam_body_1)                  { create(:exam_body) }
  let!(:group_1)                      { create(:group, exam_body_id: exam_body_1.id) }
  let!(:course_1)                     { create(:active_course,
                                               group_id: group_1.id,
                                               exam_body_id: exam_body_1.id) }

  let!(:course_section_1) { create(:course_section, course: course_1) }

  #Course Module 1
  let!(:course_lesson_1) { create(:active_course_lesson, course_section: course_section_1, course: course_1) }

  # Available on Trial
  let!(:course_step_1) { create(:course_step, :quiz_step, course_lesson: course_lesson_1, available_on_trial: true) }
  let!(:course_quiz)   { create(:course_quiz, course_step_id: course_step_1.id, question_selection_strategy: 'ordered') }

  # Available on Trial
  let!(:course_step_2)  { create(:course_step, :video_step, course_lesson: course_lesson_1, available_on_trial: true) }
  let!(:course_video_1) { create(:course_video, course_step_id: course_step_2.id, vimeo_guid: 'abc123', dacast_id: 1234) }

  # Available on Trial
  let!(:course_step_3)  { create(:course_step, :video_step, course_lesson: course_lesson_1, available_on_trial: true) }
  let!(:course_video_3) { create(:course_video, :real_video_ids, course_step_id: course_step_3.id) }

  # Available on Trial
  let!(:course_step_5)  { create(:course_step, :notes_step, course_lesson: course_lesson_1, available_on_trial: true) }
  let!(:course_note)    { create(:course_note, :file_uploaded, course_step_id: course_step_5.id) }

  # Subscription Required
  let!(:course_step_3)  { create(:course_step, :video_step, course_lesson: course_lesson_1) }
  let!(:course_video_2) { create(:course_video, course_step_id: course_step_3.id, vimeo_guid: '123abc', dacast_id: 1234) }

  let!(:course_step_4) { create(:course_step, :constructed_response_step, course_lesson: course_lesson_1, available_on_trial: true) }
  let!(:constructed_response_1) { create(:constructed_response, course_step_id: course_step_4.id) }

  let!(:quiz_question_1) { create(:quiz_question,
                                  course_step_id: course_step_1.id,
                                  course_quiz_id: course_quiz.id,
                                  course_id: course_1.id,
                                  sorting_order: 1) }
  let!(:quiz_answer_1)   { create(:correct_quiz_answer, quiz_question: quiz_question_1) }
  let!(:quiz_answer_2)   { create(:correct_quiz_answer, quiz_question: quiz_question_1) }
  let!(:quiz_answer_3)   { create(:quiz_answer, quiz_question: quiz_question_1) }
  let!(:quiz_answer_4)   { create(:quiz_answer, quiz_question: quiz_question_1) }
  let!(:quiz_content_1)  { create(:quiz_content, quiz_question: quiz_question_1) }
  let!(:quiz_content_2)  { create(:quiz_content, quiz_answer: quiz_answer_1) }
  let!(:quiz_content_3)  { create(:quiz_content, quiz_answer: quiz_answer_2) }
  let!(:quiz_content_4)  { create(:quiz_content, quiz_answer: quiz_answer_3) }
  let!(:quiz_content_5)  { create(:quiz_content,quiz_answer: quiz_answer_4) }

  let!(:quiz_question_2) { create(:quiz_question,
                                  course_step_id: course_step_1.id,
                                  course_quiz_id: course_quiz.id,
                                  course_id: course_1.id,
                                  sorting_order: 2) }
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

  # Constructed Response
  let!(:scenario_1)                  { create(:scenario, constructed_response_id: constructed_response_1.id) }
  let!(:scenario_question_1)         { create(:scenario_question, scenario_id: scenario_1.id) }
  let!(:scenario_answer_template_1)  { create(:scenario_answer_template,
                                              scenario_question_id: scenario_question_1.id,
                                              editor_type: 'text_editor') }
  let!(:scenario_answer_template_2)  { create(:scenario_answer_template,
                                              scenario_question_id: scenario_question_1.id,
                                              editor_type: 'spreadsheet_editor') }
end
