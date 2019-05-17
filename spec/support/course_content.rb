require 'rails_helper'

shared_context 'course_content' do


  #Courses first set
  let!(:course_section_1) { FactoryBot.create(:course_section,
                           subject_course: subject_course_1) }
  let!(:course_module_1) { FactoryBot.create(:active_course_module,
                           course_section: course_section_1,
                           subject_course: subject_course_1) }
  let!(:course_module_element_1_1) { FactoryBot.create(:cme_quiz,
                           course_module: course_module_1) }
  let!(:course_module_element_1_2) { FactoryBot.create(:cme_video,
                           course_module: course_module_1) }
  let!(:course_module_element_1_3) { FactoryBot.create(:cme_video,
                           course_module: course_module_1) }
  let!(:course_module_element_1_4) { FactoryBot.create(:cme_constructed_response,
                           course_module: course_module_1) }
  let!(:course_module_element_quiz_1_1) { FactoryBot.create(:course_module_element_quiz,
                           course_module_element: course_module_element_1_1) }
  let!(:course_module_element_video_1_1_1) { FactoryBot.create(:course_module_element_video,
                           course_module_element: course_module_element_1_2,
                                                                vimeo_guid: 'abc123') }
  let!(:course_module_element_video_1_1_2) { FactoryBot.create(:course_module_element_video,
                           course_module_element: course_module_element_1_3,
                                                                vimeo_guid: '123abc') }
  let!(:constructed_response_1) { FactoryBot.create(:constructed_response,
                           course_module_element: course_module_element_1_4) }

  #Courses Second set

  let!(:course_module_2) { FactoryBot.create(:active_course_module,
                                              subject_course_id: subject_course_2.id,
                                             course_section: course_section_1) }
  let!(:course_module_element_2_1) { FactoryBot.create(:cme_quiz,
                           course_module: course_module_2) }
  let!(:course_module_element_quiz_2_2_1) { FactoryBot.create(:course_module_element_quiz,
                           course_module_element: course_module_element_2_1) }

  let!(:course_module_element_2_2) { FactoryBot.create(:cme_video,
                           course_module: course_module_2, active: false) }
  let!(:course_module_element_video_2_2_2) { FactoryBot.create(:course_module_element_video,
                           course_module_element: course_module_element_2_2) }

  # Simple Question
  let!(:quiz_question_1) { FactoryBot.create(:quiz_question,
                           course_module_element_quiz: course_module_element_quiz_1_1) }
  let!(:quiz_content_1)  { FactoryBot.create(:quiz_content,
                           quiz_question: quiz_question_1) }
  let!(:quiz_answer_1)   { FactoryBot.create(:correct_quiz_answer,
                           quiz_question: quiz_question_1) }
  let!(:quiz_content_2)  { FactoryBot.create(:quiz_content,
                           quiz_answer: quiz_answer_1) }
  let!(:quiz_answer_2)   { FactoryBot.create(:correct_quiz_answer,
                           quiz_question: quiz_question_1) }
  let!(:quiz_content_3)  { FactoryBot.create(:quiz_content,
                           quiz_answer: quiz_answer_2) }
  let!(:quiz_answer_3)   { FactoryBot.create(:quiz_answer,
                           quiz_question: quiz_question_1) }
  let!(:quiz_content_4)  { FactoryBot.create(:quiz_content,
                           quiz_answer: quiz_answer_3) }
  let!(:quiz_answer_4)   { FactoryBot.create(:quiz_answer,
                           quiz_question: quiz_question_1) }
  let!(:quiz_content_5)  { FactoryBot.create(:quiz_content,
                           quiz_answer: quiz_answer_4) }

  # Complex Question
  let!(:quiz_question_2)  { FactoryBot.create(:quiz_question,
                            course_module_element_quiz: course_module_element_quiz_2_2_1) }
  let!(:quiz_content_2_1a) { FactoryBot.create(:quiz_content,
                             quiz_question: quiz_question_1) }
  let!(:quiz_content_2_1b) { FactoryBot.create(:quiz_content,
                             quiz_question: quiz_question_1) }
  let!(:quiz_answer_2_1)   { FactoryBot.create(:correct_quiz_answer,
                             quiz_question: quiz_question_2) }
  let!(:quiz_content_2_2)  { FactoryBot.create(:quiz_content,
                             quiz_answer: quiz_answer_2) }
  let!(:quiz_answer_2_2)   { FactoryBot.create(:correct_quiz_answer,
                             quiz_question: quiz_question_2) }
  let!(:quiz_content_2_3)  { FactoryBot.create(:quiz_content,
                             quiz_answer: quiz_answer_2) }
  let!(:quiz_answer_2_3)   { FactoryBot.create(:quiz_answer,
                             quiz_question: quiz_question_2) }
  let!(:quiz_content_2_4)  { FactoryBot.create(:quiz_content,
                             quiz_answer: quiz_answer_3) }
  let!(:quiz_answer_2_4)   { FactoryBot.create(:quiz_answer,
                             quiz_question: quiz_question_2) }
  let!(:quiz_content_2_5)  { FactoryBot.create(:quiz_content,
                             quiz_answer: quiz_answer_4) }


  # Constructed Response
  let!(:scenario_1)  { FactoryBot.create(:scenario, constructed_response: constructed_response_1) }

  let!(:scenario_question_1)  { FactoryBot.create(:scenario_question, scenario: scenario_1) }
  let!(:scenario_answer_template_1)  { FactoryBot.create(:scenario_answer_template,
                                                         scenario_question: scenario_question_1,
                                                         editor_type: 'text_editor') }
  let!(:scenario_answer_template_2)  { FactoryBot.create(:scenario_answer_template,
                                                         scenario_question: scenario_question_1,
                                                         editor_type: 'spreadsheet_editor') }


end
