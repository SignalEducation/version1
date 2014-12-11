require 'rails_helper'

shared_context 'course_content' do

  # Courses Structure
  let!(:subject_area_1) { FactoryGirl.create(:subject_area) }
  let!(:institution_1) { FactoryGirl.create(:institution, subject_area_id: subject_area_1.id) }
  let!(:qualification_1) { FactoryGirl.create(:qualification, institution_id: institution_1.id) }
  let!(:exam_level_1) { FactoryGirl.create(:exam_level, qualification_id: qualification_1.id) }
  let!(:course_module_1) { FactoryGirl.create(:course_module, exam_level_id: exam_level_1.id) }
  let!(:course_module_element_1) { FactoryGirl.create(:course_module_element, course_module_id: course_module_1.id) }
  let!(:course_module_element_quiz_1) { FactoryGirl.create(:course_module_element_quiz, course_module_element_id: course_module_element_1.id) }

  let!(:subject_area_2) { FactoryGirl.create(:subject_area) }
  let!(:institution_2) { FactoryGirl.create(:institution, subject_area_id: subject_area_2.id) }
  let!(:qualification_2) { FactoryGirl.create(:qualification, institution_id: institution_2.id) }
  let!(:exam_level_2) { FactoryGirl.create(:exam_level, qualification_id: qualification_2.id) }
  let!(:course_module_2) { FactoryGirl.create(:course_module, exam_level_id: exam_level_2.id) }
  let!(:course_module_element_2) { FactoryGirl.create(:course_module_element, course_module_id: course_module_2.id) }
  let!(:course_module_element_3) { FactoryGirl.create(:course_module_element, course_module_id: course_module_2.id) }
  let!(:course_module_element_quiz_2) { FactoryGirl.create(:course_module_element_quiz, course_module_element_id: course_module_element_2.id) }


  # Simple Question
  let!(:quiz_question_1) { FactoryGirl.create(:quiz_question, course_module_element_quiz_id: course_module_element_quiz_1.id) }
  let!(:quiz_content_1) { FactoryGirl.create(:quiz_content, quiz_question_id: quiz_question_1.id) }
  let!(:quiz_answer_1) { FactoryGirl.create(:quiz_answer, quiz_question_id: quiz_question.id) }
  let!(:quiz_content_2) { FactoryGirl.create(:quiz_content, quiz_answer_id: quiz_answer_1.id) }
  let!(:quiz_answer_2) { FactoryGirl.create(:quiz_answer, quiz_question_id: quiz_question_1.id) }
  let!(:quiz_content_3) { FactoryGirl.create(:quiz_content, quiz_answer_id: quiz_answer_2.id) }
  let!(:quiz_answer_3) { FactoryGirl.create(:quiz_answer, quiz_question_id: quiz_question_1.id) }
  let!(:quiz_content_4) { FactoryGirl.create(:quiz_content, quiz_answer_id: quiz_answer_3.id) }
  let!(:quiz_answer_4) { FactoryGirl.create(:quiz_answer, quiz_question_id: quiz_question_1.id) }
  let!(:quiz_content_5) { FactoryGirl.create(:quiz_content, quiz_answer_id: quiz_answer_4.id) }

  # Complex Question
  let!(:quiz_question_2) { FactoryGirl.create(:quiz_question, course_module_element_quiz_id: course_module_element_quiz_2.id) }
  let!(:quiz_content_1a) { FactoryGirl.create(:quiz_content, quiz_question_id: quiz_question_1.id) }
  let!(:quiz_content_1b) { FactoryGirl.create(:quiz_content, quiz_question_id: quiz_question_1.id) }
  let!(:quiz_answer_1) { FactoryGirl.create(:quiz_answer, quiz_question_id: quiz_question_2.id) }
  let!(:quiz_content_2) { FactoryGirl.create(:quiz_content, quiz_answer_id: quiz_answer_2.id) }
  let!(:quiz_answer_2) { FactoryGirl.create(:quiz_answer, quiz_question_id: quiz_question_2.id) }
  let!(:quiz_content_3) { FactoryGirl.create(:quiz_content, quiz_answer_id: quiz_answer_2.id) }
  let!(:quiz_answer_3) { FactoryGirl.create(:quiz_answer, quiz_question_id: quiz_question_2.id) }
  let!(:quiz_content_4) { FactoryGirl.create(:quiz_content, quiz_answer_id: quiz_answer_3.id) }
  let!(:quiz_answer_4) { FactoryGirl.create(:quiz_answer, quiz_question_id: quiz_question_2.id) }
  let!(:quiz_content_5) { FactoryGirl.create(:quiz_content, quiz_answer_id: quiz_answer_4.id) }

end