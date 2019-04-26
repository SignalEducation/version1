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
require 'support/course_content'

describe QuizQuestionsController, type: :controller do

  let(:content_management_user_group) { FactoryBot.create(:content_management_user_group) }
  let(:content_management_user) { FactoryBot.create(:content_management_user, user_group_id: content_management_user_group.id) }
  let!(:content_management_user_student_access) { FactoryBot.create(:complimentary_student_access, user_id: content_management_user.id) }
  let!(:exam_body_1) { FactoryBot.create(:exam_body) }
  let!(:group_1) { FactoryBot.create(:group) }
  let!(:group_2) { FactoryBot.create(:group) }
  let!(:subject_course_1)  { FactoryBot.create(:active_subject_course,
                                               group_id: group_1.id,
                                               exam_body_id: exam_body_1.id) }
  let!(:subject_course_2)  { FactoryBot.create(:active_subject_course,
                                               group_id: group_1.id,
                                               computer_based: true,
                                               exam_body_id: exam_body_1.id) }

  include_context 'course_content'

  let!(:valid_params) { quiz_question_1.attributes }
  let!(:invalid_params) { quiz_question_1.attributes }

  context 'Logged in as a content_management_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(content_management_user)
    end

    describe "GET 'show/1'" do
      it 'should see quiz_question_1' do
        get :show, id: quiz_question_1.id
        expect_show_success_with_model('quiz_question', quiz_question_1.id)
      end

      # optional - some other object
      it 'should see quiz_question_2' do
        get :show, id: quiz_question_2.id
        expect_show_success_with_model('quiz_question', quiz_question_2.id)
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new, cme_quiz_id: course_module_element_quiz_2_2_1.id
        expect_new_success_with_model('quiz_question')
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with quiz_question_1' do
        get :edit, id: quiz_question_1.id
        expect_edit_success_with_model('quiz_question', quiz_question_1.id)
      end

      # optional
      it 'should respond OK with quiz_question_2' do
        get :edit, id: quiz_question_2.id
        expect_edit_success_with_model('quiz_question', quiz_question_2.id)
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, quiz_question: valid_params
        expect_create_success_with_model('quiz_question', edit_course_module_element_url(course_module_element_1_1.id))
      end

    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for quiz_question_1' do
        put :update, id: quiz_question_1.id, quiz_question: valid_params
        expect_update_success_with_model('quiz_question', edit_course_module_element_url(quiz_question_1.course_module_element_quiz.course_module_element.id))
      end

      # optional
      it 'should respond OK to valid params for quiz_question_2' do
        put :update, id: quiz_question_2.id, quiz_question: valid_params
        expect_update_success_with_model('quiz_question', edit_course_module_element_url(course_module_element_1_1.id))
        expect(assigns(:quiz_question).id).to eq(quiz_question_2.id)
      end

    end


    describe "DELETE 'destroy'" do

      let!(:quiz_attempt) { FactoryBot.create(:quiz_attempt, quiz_question_id: quiz_question_1.id) }

      it 'should be ERROR as children exist' do
        delete :destroy, id: quiz_question_1.id
        expect_archive_success_with_model('quiz_question', quiz_question_2.id, edit_course_module_element_url(course_module_element_1_1.id))
      end

      it 'should be OK as no dependencies exist' do
        quiz_question_2.quiz_attempts.destroy_all
        delete :destroy, id: quiz_question_2.id
        expect_delete_success_with_model('quiz_question', edit_course_module_element_url(quiz_question_2.course_module_element_id))
      end
    end

  end

end
