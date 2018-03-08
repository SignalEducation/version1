require 'rails_helper'

shared_context 'course_content' do


  #Courses first set
  let!(:course_module_1) { FactoryBot.create(:active_course_module,
                           subject_course_id: subject_course_1.id) }
  let!(:course_module_element_1_1) { FactoryBot.create(:cme_quiz,
                           course_module_id: course_module_1.id) }
  let!(:course_module_element_1_2) { FactoryBot.create(:cme_video,
                           course_module_id: course_module_1.id) }
  let!(:course_module_element_1_3) { FactoryBot.create(:cme_video,
                           course_module_id: course_module_1.id) }
  let!(:course_module_element_quiz_1_1) { FactoryBot.create(:course_module_element_quiz,
                           course_module_element_id: course_module_element_1_1.id) }
  let!(:course_module_element_video_1_1_1) { FactoryBot.create(:course_module_element_video,
                           course_module_element_id: course_module_element_1_2.id,
                                                                vimeo_guid: 'abc123') }
  let!(:course_module_element_video_1_1_2) { FactoryBot.create(:course_module_element_video,
                           course_module_element_id: course_module_element_1_3.id,
                                                                vimeo_guid: '123abc') }

  #Courses Second set

  let!(:course_module_2) { FactoryBot.create(:active_course_module,
                                              subject_course_id: subject_course_2.id) }
  let!(:course_module_element_2_1) { FactoryBot.create(:cme_quiz,
                           course_module_id: course_module_2.id) }
  let!(:course_module_element_quiz_2_2_1) { FactoryBot.create(:course_module_element_quiz,
                           course_module_element_id: course_module_element_2_1.id) }

  let!(:course_module_element_2_2) { FactoryBot.create(:cme_video,
                           course_module_id: course_module_2.id, active: false) }
  let!(:course_module_element_video_2_2_2) { FactoryBot.create(:course_module_element_video,
                           course_module_element_id: course_module_element_2_2.id) }

  # Simple Question
  let!(:quiz_question_1) { FactoryBot.create(:quiz_question,
                           course_module_element_quiz_id: course_module_element_quiz_1_1.id) }
  let!(:quiz_content_1)  { FactoryBot.create(:quiz_content,
                           quiz_question_id: quiz_question_1.id) }
  let!(:quiz_answer_1)   { FactoryBot.create(:quiz_answer,
                           quiz_question_id: quiz_question_1.id) }
  let!(:quiz_content_2)  { FactoryBot.create(:quiz_content,
                           quiz_answer_id: quiz_answer_1.id) }
  let!(:quiz_answer_2)   { FactoryBot.create(:quiz_answer,
                           quiz_question_id: quiz_question_1.id) }
  let!(:quiz_content_3)  { FactoryBot.create(:quiz_content,
                           quiz_answer_id: quiz_answer_2.id) }
  let!(:quiz_answer_3)   { FactoryBot.create(:quiz_answer,
                           quiz_question_id: quiz_question_1.id) }
  let!(:quiz_content_4)  { FactoryBot.create(:quiz_content,
                           quiz_answer_id: quiz_answer_3.id) }
  let!(:quiz_answer_4)   { FactoryBot.create(:quiz_answer,
                           quiz_question_id: quiz_question_1.id) }
  let!(:quiz_content_5)  { FactoryBot.create(:quiz_content,
                           quiz_answer_id: quiz_answer_4.id) }

  # Complex Question
  let!(:quiz_question_2)  { FactoryBot.create(:quiz_question,
                            course_module_element_quiz_id: course_module_element_quiz_2_2_1.id) }
  let!(:quiz_content_2_1a) { FactoryBot.create(:quiz_content,
                             quiz_question_id: quiz_question_1.id) }
  let!(:quiz_content_2_1b) { FactoryBot.create(:quiz_content,
                             quiz_question_id: quiz_question_1.id) }
  let!(:quiz_answer_2_1)   { FactoryBot.create(:quiz_answer,
                             quiz_question_id: quiz_question_2.id) }
  let!(:quiz_content_2_2)  { FactoryBot.create(:quiz_content,
                             quiz_answer_id: quiz_answer_2.id) }
  let!(:quiz_answer_2_2)   { FactoryBot.create(:quiz_answer,
                             quiz_question_id: quiz_question_2.id) }
  let!(:quiz_content_2_3)  { FactoryBot.create(:quiz_content,
                             quiz_answer_id: quiz_answer_2.id) }
  let!(:quiz_answer_2_3)   { FactoryBot.create(:quiz_answer,
                             quiz_question_id: quiz_question_2.id) }
  let!(:quiz_content_2_4)  { FactoryBot.create(:quiz_content,
                             quiz_answer_id: quiz_answer_3.id) }
  let!(:quiz_answer_2_4)   { FactoryBot.create(:quiz_answer,
                             quiz_question_id: quiz_question_2.id) }
  let!(:quiz_content_2_5)  { FactoryBot.create(:quiz_content,
                             quiz_answer_id: quiz_answer_4.id) }


  let!(:home) { FactoryBot.create(:home_page, public_url: '/', home: true, group_id: course_group_1.id) }

end
