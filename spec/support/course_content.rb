require 'rails_helper'

shared_context 'course_content' do

  # Courses Structure

  # first set
  let!(:course_group_1) { FactoryGirl.create(:group) }
  let!(:subject_course_1)  { FactoryGirl.create(:active_subject_course, groups: [course_group_1]) }
  let!(:course_module_1) { FactoryGirl.create(:active_course_module,
                           subject_course_id: subject_course_1.id,
                           tutor_id: tutor_user.id) }
  let!(:course_module_element_1_1) { FactoryGirl.create(:cme_quiz,
                           course_module_id: course_module_1.id) }
  let!(:course_module_element_1_2) { FactoryGirl.create(:cme_video,
                           course_module_id: course_module_1.id) }
  let!(:course_module_element_1_3) { FactoryGirl.create(:cme_video,
                           course_module_id: course_module_1.id) }
  let!(:course_module_element_quiz_1_1) { FactoryGirl.create(:course_module_element_quiz,
                           course_module_element_id: course_module_element_1_1.id) }
  let!(:course_module_element_video_1_1_1) { FactoryGirl.create(:course_module_element_video,
                           course_module_element_id: course_module_element_1_2.id,
                                                                video_id: 'abc123') }
  let!(:course_module_element_video_1_1_2) { FactoryGirl.create(:course_module_element_video,
                           course_module_element_id: course_module_element_1_3.id,
                                                                video_id: '123abc') }

  # Second set
  let!(:course_group_2) { FactoryGirl.create(:group) }
  let!(:subject_course_2)    { FactoryGirl.create(:active_subject_course, groups: [course_group_2]) }

  let!(:course_module_2) { FactoryGirl.create(:active_course_module,
                                              subject_course_id: subject_course_2.id,
                                              tutor_id: tutor_user.id) }
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
