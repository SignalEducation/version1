require 'rails_helper'

shared_context 'course_content' do

  # Courses Structure
  let!(:subject_area) { FactoryGirl.create(:subject_area) }
  let!(:institution) { FactoryGirl.create(:institution, subject_area_id: subject_area.id) }
  let!(:qualification) { FactoryGirl.create(:qualification, institution_id: institution.id) }
  let!(:exam_level) { FactoryGirl.create(:exam_level, qualification_id: qualification.id) }
  let!(:course_module) { FactoryGirl.create(:course_module, exam_level_id: exam_level.id) }
  let!(:course_module_element) { FactoryGirl.create(:course_module_element, course_module_id: course_module.id) }
  let!(:course_module_element_quiz) { FactoryGirl.create(:course_module_element_quiz, course_module_element_id: course_module_element.id) }

  # Simple Question
  let!(:quiz_question_1) { FactoryGirl.create(:quiz_question, course_module_element_quiz_id: course_module_element_quiz.id) }
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
  let!(:quiz_question_2) { FactoryGirl.create(:quiz_question, course_module_element_quiz_id: course_module_element_quiz.id) }
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