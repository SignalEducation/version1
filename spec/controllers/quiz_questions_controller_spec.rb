# == Schema Information
#
# Table name: quiz_questions
#
#  id                            :integer          not null, primary key
#  course_module_element_quiz_id :integer
#  course_module_element_id      :integer
#  difficulty_level              :string
#  created_at                    :datetime
#  updated_at                    :datetime
#  destroyed_at                  :datetime
#  subject_course_id             :integer
#  sorting_order                 :integer
#  custom_styles                 :boolean          default(FALSE)
#

require 'rails_helper'

describe QuizQuestionsController, type: :controller do

  let(:content_management_user_group) { FactoryBot.create(:content_management_user_group) }
  let(:content_management_user) { FactoryBot.create(:content_management_user, user_group_id: content_management_user_group.id) }

  let!(:exam_body_1) { FactoryBot.create(:exam_body) }
  let!(:group_1) { FactoryBot.create(:group) }
  let!(:subject_course_1)  { FactoryBot.create(:active_subject_course,
                                               group_id: group_1.id,
                                               exam_body_id: exam_body_1.id) }
  let!(:course_section_1) { FactoryBot.create(:course_section,
                                              subject_course: subject_course_1) }
  let!(:course_module_1) { FactoryBot.create(:active_course_module,
                                             subject_course_id: subject_course_1.id,
                                             course_section: course_section_1) }
  let!(:course_module_element_2_1) { FactoryBot.create(:cme_quiz,
                                                       course_module: course_module_1) }
  let!(:course_module_element_quiz_1_1) { FactoryBot.create(:course_module_element_quiz,
                                                              course_module_element: course_module_element_2_1) }
  let!(:quiz_question_1) { FactoryBot.create(:quiz_question,
                                             course_module_element_id: course_module_element_2_1.id,
                                             course_module_element_quiz: course_module_element_quiz_1_1,
                                             subject_course_id: subject_course_1.id) }
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


  let!(:valid_params) { quiz_question_1.attributes }
  let!(:invalid_params) { quiz_question_1.attributes }

  context 'Logged in as a content_management_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(content_management_user)
    end

    describe "GET 'show/1'" do
      it 'should see quiz_question_1' do
        get :show, params: { id: quiz_question_1.id }
        expect_show_success_with_model('quiz_question', quiz_question_1.id)
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new, params: { cme_quiz_id: course_module_element_quiz_1_1.id }
        expect_new_success_with_model('quiz_question')
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with quiz_question_1' do
        get :edit, params: { id: quiz_question_1.id }
        expect_edit_success_with_model('quiz_question', quiz_question_1.id)
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, params: { quiz_question: valid_params }
        expect_create_success_with_model('quiz_question', edit_course_module_element_url(course_module_element_2_1.id))
      end

    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for quiz_question_1' do
        put :update, params: { id: quiz_question_1.id, quiz_question: valid_params }
        expect_update_success_with_model('quiz_question', edit_course_module_element_url(quiz_question_1.course_module_element_quiz.course_module_element.id))
      end

      # optional
      it 'should respond OK to valid params for quiz_question_2' do
        put :update, params: { id: quiz_question_1.id, quiz_question: valid_params }
        expect_update_success_with_model('quiz_question', edit_course_module_element_url(course_module_element_2_1.id))
        expect(assigns(:quiz_question).id).to eq(quiz_question_1.id)
      end

    end


    describe "DELETE 'destroy'" do

      it 'should be ERROR as children exist' do
        delete :destroy, params: { id: quiz_question_1.id }
        expect_archive_success_with_model('quiz_question', quiz_question_1.id, edit_course_module_element_url(course_module_element_2_1.id))
      end

      xit 'should be OK as no dependencies exist' do
        quiz_question_2.quiz_attempts.destroy_all
        delete :destroy, params: { id: quiz_question_2.id }
        expect_delete_success_with_model('quiz_question', edit_course_module_element_url(quiz_question_2.course_module_element_id))
      end
    end

  end

end
