require 'rails_helper'

shared_context 'course_content' do
  let!(:course_section_1) { create(:course_section, subject_course: subject_course_1) }

  #Course Module 1
  let!(:course_module_1) { create(:active_course_module, course_section: course_section_1, subject_course: subject_course_1) }

  # Available on Trial
  let!(:course_module_element_1)    { create(:course_module_element, :cme_quiz, course_module: course_module_1, available_on_trial: true) }
  let!(:course_module_element_quiz) { create(:course_module_element_quiz, course_module_element_id: course_module_element_1.id) }

  # Available on Trial
  let!(:course_module_element_2)       { create(:course_module_element, :cme_video, course_module: course_module_1, available_on_trial: true) }
  let!(:course_module_element_video_1) { create(:course_module_element_video, course_module_element_id: course_module_element_2.id, vimeo_guid: 'abc123', dacast_id: 1234) }

  # Subscription Required
  let!(:course_module_element_3)       { create(:course_module_element, :cme_video, course_module: course_module_1) }
  let!(:course_module_element_video_2) { create(:course_module_element_video, course_module_element_id: course_module_element_3.id, vimeo_guid: '123abc', dacast_id: 1234) }

  let!(:course_module_element_4) { create(:course_module_element, :cme_constructed_response, course_module: course_module_1, available_on_trial: true) }
  let!(:constructed_response_1)  { create(:constructed_response, course_module_element_id: course_module_element_4.id) }

  let!(:quiz_question_1) { create(:quiz_question,
                                  course_module_element_id: course_module_element_1.id,
                                  course_module_element_quiz_id: course_module_element_quiz.id,
                                  subject_course_id: subject_course_1.id) }
  let!(:quiz_content_1)  { create(:quiz_content, quiz_question: quiz_question_1) }
  let!(:quiz_content_2)  { create(:quiz_content, quiz_answer: quiz_answer_1) }
  let!(:quiz_content_3)  { create(:quiz_content, quiz_answer: quiz_answer_2) }
  let!(:quiz_content_4)  { create(:quiz_content, quiz_answer: quiz_answer_3) }
  let!(:quiz_answer_1)   { create(:correct_quiz_answer, quiz_question: quiz_question_1) }
  let!(:quiz_answer_2)   { create(:correct_quiz_answer, quiz_question: quiz_question_1) }
  let!(:quiz_answer_3)   { create(:quiz_answer, quiz_question: quiz_question_1) }
  let!(:quiz_answer_4)   { create(:quiz_answer, quiz_question: quiz_question_1) }
  let!(:quiz_content_5)  { create(:quiz_content,quiz_answer: quiz_answer_4) }

  let!(:quiz_question_2)  { create(:quiz_question,
                                              course_module_element_id: course_module_element_1.id,
                                              course_module_element_quiz_id: course_module_element_quiz.id,
                                              subject_course_id: subject_course_1.id) }
  let!(:quiz_content_2_1a) { create(:quiz_content, quiz_question: quiz_question_1) }
  let!(:quiz_content_2_1b) { create(:quiz_content, quiz_question: quiz_question_1) }
  let!(:quiz_content_2_2)  { create(:quiz_content, quiz_answer: quiz_answer_2) }
  let!(:quiz_content_2_3)  { create(:quiz_content, quiz_answer: quiz_answer_2) }
  let!(:quiz_content_2_4)  { create(:quiz_content, quiz_answer: quiz_answer_3) }
  let!(:quiz_answer_2_4)   { create(:quiz_answer, quiz_question: quiz_question_2) }
  let!(:quiz_answer_2_1)   { create(:correct_quiz_answer, quiz_question: quiz_question_2) }
  let!(:quiz_answer_2_2)   { create(:correct_quiz_answer, quiz_question: quiz_question_2) }
  let!(:quiz_answer_2_3)   { create(:quiz_answer, quiz_question: quiz_question_2) }
  let!(:quiz_content_2_5)  { create(:quiz_content, quiz_answer: quiz_answer_4) }


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
