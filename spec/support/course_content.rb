require 'rails_helper'

shared_context 'course_content' do

  # Courses Structure

  # first set
  let!(:subject_area_1)  { FactoryGirl.create(:active_subject_area) }
  let!(:institution_1)   { FactoryGirl.create(:active_institution,
                           subject_area_id: subject_area_1.id) }
  let!(:qualification_1) { FactoryGirl.create(:active_qualification,
                           institution_id: institution_1.id) }
  let!(:exam_level_1)    { FactoryGirl.create(:active_exam_level_with_exam_sections,
                           qualification_id: qualification_1.id) }
  let!(:exam_section_1)  { FactoryGirl.create(:active_exam_section,
                           exam_level_id: exam_level_1.id) }

  let!(:course_module_1) { FactoryGirl.create(:active_course_module,
                           qualification_id: qualification_1.id,
                           exam_section_id: exam_section_1.id) }
  let!(:course_module_element_1_1) { FactoryGirl.create(:cme_quiz,
                           course_module_id: course_module_1.id) }
  let!(:course_module_element_1_2) { FactoryGirl.create(:cme_video,
                           course_module_id: course_module_1.id) }
  let!(:course_module_element_quiz_1_1) { FactoryGirl.create(:course_module_element_quiz,
                           course_module_element_id: course_module_element_1_1.id) }
  let!(:course_module_element_video_1_1_1) { FactoryGirl.create(:course_module_element_video,
                           course_module_element_id: course_module_element_1_2.id) }

  # Second set
  let!(:subject_area_2)  { FactoryGirl.create(:active_subject_area) }
  let!(:institution_2)   { FactoryGirl.create(:active_institution,
                           subject_area_id: subject_area_2.id) }
  let!(:qualification_2) { FactoryGirl.create(:active_qualification,
                           institution_id: institution_2.id) }
  let!(:exam_level_2)    { FactoryGirl.create(:active_exam_level_without_exam_sections,
                           qualification_id: qualification_2.id) }

  let!(:course_module_2) { FactoryGirl.create(:active_course_module,
                           qualification_id: qualification_2.id,
                           exam_level_id: exam_level_2.id) }
  let!(:course_module_element_2_1) { FactoryGirl.create(:cme_quiz,
                           course_module_id: course_module_2.id) }
  let!(:course_module_element_quiz_2_2_1) { FactoryGirl.create(:course_module_element_quiz,
                           course_module_element_id: course_module_element_2_1.id) }

  let!(:course_module_element_2_2) { FactoryGirl.create(:cme_video,
                           course_module_id: course_module_2.id, active: false) }
  let!(:course_module_element_video_2_2_2) { FactoryGirl.create(:course_module_element_video,
                           course_module_element_id: course_module_element_2_2.id) }

  # Simple Question
  let!(:quiz_question_1) { FactoryGirl.create(:quiz_question,
                           course_module_element_quiz_id: course_module_element_quiz_1_1.id) }
  let!(:quiz_content_1)  { FactoryGirl.create(:quiz_content,
                           quiz_question_id: quiz_question_1.id) }
  let!(:quiz_answer_1)   { FactoryGirl.create(:quiz_answer,
                           quiz_question_id: quiz_question_1.id) }
  let!(:quiz_content_2)  { FactoryGirl.create(:quiz_content,
                           quiz_answer_id: quiz_answer_1.id) }
  let!(:quiz_answer_2)   { FactoryGirl.create(:quiz_answer,
                           quiz_question_id: quiz_question_1.id) }
  let!(:quiz_content_3)  { FactoryGirl.create(:quiz_content,
                           quiz_answer_id: quiz_answer_2.id) }
  let!(:quiz_answer_3)   { FactoryGirl.create(:quiz_answer,
                           quiz_question_id: quiz_question_1.id) }
  let!(:quiz_content_4)  { FactoryGirl.create(:quiz_content,
                           quiz_answer_id: quiz_answer_3.id) }
  let!(:quiz_answer_4)   { FactoryGirl.create(:quiz_answer,
                           quiz_question_id: quiz_question_1.id) }
  let!(:quiz_content_5)  { FactoryGirl.create(:quiz_content,
                           quiz_answer_id: quiz_answer_4.id) }

  # Complex Question
  let!(:quiz_question_2)  { FactoryGirl.create(:quiz_question,
                            course_module_element_quiz_id: course_module_element_quiz_2_2_1.id) }
  let!(:quiz_content_2_1a) { FactoryGirl.create(:quiz_content,
                             quiz_question_id: quiz_question_1.id) }
  let!(:quiz_content_2_1b) { FactoryGirl.create(:quiz_content,
                             quiz_question_id: quiz_question_1.id) }
  let!(:quiz_answer_2_1)   { FactoryGirl.create(:quiz_answer,
                             quiz_question_id: quiz_question_2.id) }
  let!(:quiz_content_2_2)  { FactoryGirl.create(:quiz_content,
                             quiz_answer_id: quiz_answer_2.id) }
  let!(:quiz_answer_2_2)   { FactoryGirl.create(:quiz_answer,
                             quiz_question_id: quiz_question_2.id) }
  let!(:quiz_content_2_3)  { FactoryGirl.create(:quiz_content,
                             quiz_answer_id: quiz_answer_2.id) }
  let!(:quiz_answer_2_3)   { FactoryGirl.create(:quiz_answer,
                             quiz_question_id: quiz_question_2.id) }
  let!(:quiz_content_2_4)  { FactoryGirl.create(:quiz_content,
                             quiz_answer_id: quiz_answer_3.id) }
  let!(:quiz_answer_2_4)   { FactoryGirl.create(:quiz_answer,
                             quiz_question_id: quiz_question_2.id) }
  let!(:quiz_content_2_5)  { FactoryGirl.create(:quiz_content,
                             quiz_answer_id: quiz_answer_4.id) }

end
