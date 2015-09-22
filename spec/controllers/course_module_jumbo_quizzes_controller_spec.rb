require 'rails_helper'
require 'support/users_and_groups_setup'
require 'support/course_content'

describe CourseModuleJumboQuizzesController, type: :controller do

  include_context 'users_and_groups_setup'
  include_context 'course_content'

  let!(:course_module_jumbo_quiz_1) { FactoryGirl.create(:course_module_jumbo_quiz) }
  let!(:course_module_jumbo_quiz_2) { FactoryGirl.create(:course_module_jumbo_quiz) }
  let!(:valid_params) { FactoryGirl.attributes_for(:course_module_jumbo_quiz) }

  context 'Not logged in: ' do

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

  end

  context 'Logged in as a individual_student_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(individual_student_user)
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
        post :create, course_module_jumbo_quiz: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond ERROR not permitted' do
        put :update, id: 1, course_module_jumbo_quiz: valid_params
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a tutor_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(tutor_user)
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_new_success_with_model('course_module_jumbo_quiz')
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with course_module_jumbo_quiz_1' do
        get :edit, id: course_module_jumbo_quiz_1.id
        expect_edit_success_with_model('course_module_jumbo_quiz', course_module_jumbo_quiz_1.id)
      end

      # optional
      it 'should respond OK with course_module_jumbo_quiz_2' do
        get :edit, id: course_module_jumbo_quiz_2.id
        expect_edit_success_with_model('course_module_jumbo_quiz', course_module_jumbo_quiz_2.id)
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, course_module_jumbo_quiz: valid_params
        expect_create_success_with_model('course_module_jumbo_quiz', subject_course_url(course_module_jumbo_quiz_1.course_module.subject_course))
      end

      it 'should report error for invalid params' do
        post :create, course_module_jumbo_quiz: {valid_params.keys.first => ''}
        expect_create_error_with_model('course_module_jumbo_quiz')
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for course_module_jumbo_quiz_1' do
        put :update, id: course_module_jumbo_quiz_1.id, course_module_jumbo_quiz: valid_params
        expect_update_success_with_model('course_module_jumbo_quiz', subject_course_url(course_module_jumbo_quiz_1.course_module.subject_course))
      end

      # optional
      it 'should respond OK to valid params for course_module_jumbo_quiz_2' do
        put :update, id: course_module_jumbo_quiz_2.id, course_module_jumbo_quiz: valid_params
        expect_update_success_with_model('course_module_jumbo_quiz', course_module_jumbo_quiz_2.course_module.subject_course)
        expect(assigns(:course_module_jumbo_quiz).id).to eq(course_module_jumbo_quiz_2.id)
      end

      it 'should reject invalid params' do
        put :update, id: course_module_jumbo_quiz_1.id, course_module_jumbo_quiz: {valid_params.keys.first => ''}
        expect_update_error_with_model('course_module_jumbo_quiz')
        expect(assigns(:course_module_jumbo_quiz).id).to eq(course_module_jumbo_quiz_1.id)
      end
    end

  end

  context 'Logged in as a corporate_student_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(corporate_student_user)
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
        post :create, course_module_jumbo_quiz: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond ERROR not permitted' do
        put :update, id: 1, course_module_jumbo_quiz: valid_params
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a corporate_customer_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(corporate_customer_user)
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
        post :create, course_module_jumbo_quiz: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond ERROR not permitted' do
        put :update, id: 1, course_module_jumbo_quiz: valid_params
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a blogger_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(blogger_user)
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
        post :create, course_module_jumbo_quiz: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond ERROR not permitted' do
        put :update, id: 1, course_module_jumbo_quiz: valid_params
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a forum_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(forum_manager_user)
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
        post :create, course_module_jumbo_quiz: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond ERROR not permitted' do
        put :update, id: 1, course_module_jumbo_quiz: valid_params
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a content_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(content_manager_user)
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_new_success_with_model('course_module_jumbo_quiz')
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with course_module_jumbo_quiz_1' do
        get :edit, id: course_module_jumbo_quiz_1.id
        expect_edit_success_with_model('course_module_jumbo_quiz', course_module_jumbo_quiz_1.id)
      end

      # optional
      it 'should respond OK with course_module_jumbo_quiz_2' do
        get :edit, id: course_module_jumbo_quiz_2.id
        expect_edit_success_with_model('course_module_jumbo_quiz', course_module_jumbo_quiz_2.id)
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, course_module_jumbo_quiz: valid_params
        expect_create_success_with_model('course_module_jumbo_quiz', subject_course_url(course_module_jumbo_quiz_1.course_module.subject_course))
      end

      it 'should report error for invalid params' do
        post :create, course_module_jumbo_quiz: {valid_params.keys.first => ''}
        expect_create_error_with_model('course_module_jumbo_quiz')
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for course_module_jumbo_quiz_1' do
        put :update, id: course_module_jumbo_quiz_1.id, course_module_jumbo_quiz: valid_params
        expect_update_success_with_model('course_module_jumbo_quiz', subject_course_url(course_module_jumbo_quiz_1.course_module.subject_course))
      end

      # optional
      it 'should respond OK to valid params for course_module_jumbo_quiz_2' do
        put :update, id: course_module_jumbo_quiz_2.id, course_module_jumbo_quiz: valid_params
        expect_update_success_with_model('course_module_jumbo_quiz', subject_course_url(course_module_jumbo_quiz_1.course_module.subject_course))
        expect(assigns(:course_module_jumbo_quiz).id).to eq(course_module_jumbo_quiz_2.id)
      end

      it 'should reject invalid params' do
        put :update, id: course_module_jumbo_quiz_1.id, course_module_jumbo_quiz: {valid_params.keys.first => ''}
        expect_update_error_with_model('course_module_jumbo_quiz')
        expect(assigns(:course_module_jumbo_quiz).id).to eq(course_module_jumbo_quiz_1.id)
      end
    end

  end

  context 'Logged in as a admin_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(admin_user)
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_new_success_with_model('course_module_jumbo_quiz')
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with course_module_jumbo_quiz_1' do
        get :edit, id: course_module_jumbo_quiz_1.id
        expect_edit_success_with_model('course_module_jumbo_quiz', course_module_jumbo_quiz_1.id)
      end

      # optional
      it 'should respond OK with course_module_jumbo_quiz_2' do
        get :edit, id: course_module_jumbo_quiz_2.id
        expect_edit_success_with_model('course_module_jumbo_quiz', course_module_jumbo_quiz_2.id)
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, course_module_jumbo_quiz: valid_params
        expect_create_success_with_model('course_module_jumbo_quiz', subject_course_url(course_module_1.subject_course))
      end

      it 'should report error for invalid params' do
        post :create, course_module_jumbo_quiz: {valid_params.keys.first => ''}
        expect_create_error_with_model('course_module_jumbo_quiz')
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for course_module_jumbo_quiz_1' do
        put :update, id: course_module_jumbo_quiz_1.id, course_module_jumbo_quiz: valid_params
        expect_update_success_with_model('course_module_jumbo_quiz', subject_course_url(course_module_jumbo_quiz_1.course_module.subject_course))
      end

      # optional
      it 'should respond OK to valid params for course_module_jumbo_quiz_2' do
        put :update, id: course_module_jumbo_quiz_2.id, course_module_jumbo_quiz: valid_params
        expect_update_success_with_model('course_module_jumbo_quiz', subject_course_url(course_module_jumbo_quiz_1.course_module.subject_course))
        expect(assigns(:course_module_jumbo_quiz).id).to eq(course_module_jumbo_quiz_2.id)
      end

      it 'should reject invalid params' do
        put :update, id: course_module_jumbo_quiz_1.id, course_module_jumbo_quiz: {valid_params.keys.first => ''}
        expect_update_error_with_model('course_module_jumbo_quiz')
        expect(assigns(:course_module_jumbo_quiz).id).to eq(course_module_jumbo_quiz_1.id)
      end
    end

  end

end
