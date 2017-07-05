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
require 'support/users_and_groups_setup'
require 'support/course_content'

describe QuizQuestionsController, type: :controller do

  include_context 'users_and_groups_setup'
  include_context 'course_content'

  let!(:valid_params) { quiz_question_1.attributes }
  #let!(:valid_params) { FactoryGirl.attributes_for(:quiz_question_1) }

  context 'Not logged in: ' do

    describe "GET 'show/1'" do
      it 'should redirect to sign_in' do
        get :show, id: 1
        expect_bounce_as_not_signed_in
      end
    end

    describe "GET 'new'" do
      it 'should redirect to sign_in' do
        get :new
        expect_bounce_as_not_signed_in
      end
    end

    describe "GET 'edit/1'" do
      it 'should redirect to sign_in' do
        get :edit, id: 1
        expect_bounce_as_not_signed_in
      end
    end

    describe "POST 'create'" do
      it 'should redirect to sign_in' do
        post :create, user: valid_params
        expect_bounce_as_not_signed_in
      end
    end

    describe "PUT 'update/1'" do
      it 'should redirect to sign_in' do
        put :update, id: 1, user: valid_params
        expect_bounce_as_not_signed_in
      end
    end

    describe "POST 'reorder'" do
      it 'should be OK with valid_array' do
        post :create, array_of_ids: [1,2]
        expect_bounce_as_not_signed_in
      end
    end

    describe "DELETE 'destroy'" do
      it 'should redirect to sign_in' do
        delete :destroy, id: 1
        expect_bounce_as_not_signed_in
      end
    end

  end

  context 'Logged in as a individual_student_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(individual_student_user)
    end

    describe "GET 'show/1'" do
      it 'should respond ERROR not permitted' do
        get :show, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      it 'should respond ERROR not permitted' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond ERROR not permitted' do
        get :edit, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should respond ERROR not permitted' do
        post :create, quiz_question: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond ERROR not permitted' do
        put :update, id: 1, quiz_question: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "DELETE 'destroy'" do
      it 'should respond ERROR not permitted' do
        delete :destroy, id: 1
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a complimentary_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(comp_user)
    end

    describe "GET 'show/1'" do
      it 'should respond ERROR not permitted' do
        get :show, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      it 'should respond ERROR not permitted' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond ERROR not permitted' do
        get :edit, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should respond ERROR not permitted' do
        post :create, quiz_question: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond ERROR not permitted' do
        put :update, id: 1, quiz_question: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "DELETE 'destroy'" do
      it 'should respond ERROR not permitted' do
        delete :destroy, id: 1
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a tutor_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(tutor_user)
    end

    describe "GET 'show/1'" do
      it 'should see quiz_question_1' do
        get :show, id: quiz_question_1.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new, cme_quiz_id: course_module_element_quiz_2_2_1.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with quiz_question_1' do
        get :edit, id: quiz_question_1.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, quiz_question: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for quiz_question_1' do
        put :update, id: quiz_question_1.id, quiz_question: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should reject invalid params' do
        put :update, id: quiz_question_1.id, quiz_question: { difficulty_level: 'Bad' }
        expect_bounce_as_not_allowed
      end
    end

    describe "DELETE 'destroy'" do
      let!(:quiz_attempt) { FactoryGirl.create(:quiz_attempt, quiz_question_id: quiz_question_1.id) }

      it 'should be ERROR as children exist' do
        delete :destroy, id: quiz_question_1.id
        expect_bounce_as_not_allowed
      end

      it 'should be OK as no dependencies exist' do
        quiz_question_2.quiz_attempts.destroy_all
        delete :destroy, id: quiz_question_2.id
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a blogger_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(blogger_user)
    end

    describe "GET 'show/1'" do
      it 'should respond ERROR not permitted' do
        get :show, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      it 'should respond ERROR not permitted' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond ERROR not permitted' do
        get :edit, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should respond ERROR not permitted' do
        post :create, quiz_question: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond ERROR not permitted' do
        put :update, id: 1, quiz_question: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "DELETE 'destroy'" do
      it 'should respond ERROR not permitted' do
        delete :destroy, id: 1
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a content_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(content_manager_user)
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

      it 'should report error for invalid params' do
        post :create, quiz_question: {valid_params.keys.first => ''}
        expect_create_error_with_model('quiz_question')
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

      it 'should reject invalid params' do
        put :update, id: quiz_question_1.id, quiz_question: { difficulty_level: 'Bad' }
        expect_update_error_with_model('quiz_question')
        expect(assigns(:quiz_question).id).to eq(quiz_question_1.id)
      end
    end


    describe "DELETE 'destroy'" do

      let!(:quiz_attempt) { FactoryGirl.create(:quiz_attempt, quiz_question_id: quiz_question_1.id) }

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

  context 'Logged in as a customer_support_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(customer_support_manager_user)
    end

    describe "GET 'show/1'" do
      it 'should respond ERROR not permitted' do
        get :show, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      it 'should respond ERROR not permitted' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond ERROR not permitted' do
        get :edit, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should respond ERROR not permitted' do
        post :create, quiz_question: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond ERROR not permitted' do
        put :update, id: 1, quiz_question: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "DELETE 'destroy'" do
      it 'should respond ERROR not permitted' do
        delete :destroy, id: 1
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a marketing_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(marketing_manager_user)
    end

    describe "GET 'show/1'" do
      it 'should respond ERROR not permitted' do
        get :show, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      it 'should respond ERROR not permitted' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond ERROR not permitted' do
        get :edit, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should respond ERROR not permitted' do
        post :create, quiz_question: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond ERROR not permitted' do
        put :update, id: 1, quiz_question: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "DELETE 'destroy'" do
      it 'should respond ERROR not permitted' do
        delete :destroy, id: 1
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a admin_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(admin_user)
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

      it 'should report error for invalid params' do
        post :create, quiz_question: {valid_params.keys.first => ''}
        expect_create_error_with_model('quiz_question')
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

      it 'should reject invalid params' do
        put :update, id: quiz_question_1.id, quiz_question: { difficulty_level: 'Bad' }
        expect_update_error_with_model('quiz_question')
        expect(assigns(:quiz_question).id).to eq(quiz_question_1.id)
      end
    end


    describe "DELETE 'destroy'" do

      let!(:quiz_attempt) { FactoryGirl.create(:quiz_attempt, quiz_question_id: quiz_question_1.id) }

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
