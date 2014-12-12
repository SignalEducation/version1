require 'rails_helper'
require 'support/users_and_groups_setup'
require 'support/course_content'

describe CourseModuleElementsController, type: :controller do

  include_context 'users_and_groups_setup'
  include_context 'course_content'

  let!(:valid_params) { course_module_element_1.attributes.merge({name: 'ABCDE', name_url: 'adcbw'}) }

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
        post :create, course_module_element: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond ERROR not permitted' do
        put :update, id: 1, course_module_element: valid_params
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

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new, cm_id: course_module_1.id
        expect_new_success_with_model('course_module_element')
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with course_module_element_1' do
        get :edit, id: course_module_element_1.id
        expect_edit_success_with_model('course_module_element', course_module_element_1.id)
      end

      # optional
      it 'should respond OK with course_module_element_2' do
        get :edit, id: course_module_element_2.id
        expect_edit_success_with_model('course_module_element', course_module_element_2.id)
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, course_module_element: valid_params
        expect_create_success_with_model('course_module_element', edit_course_module_element_url(CourseModuleElement.last.id))
      end

      it 'should report error for invalid params' do
        post :create, course_module_element: {valid_params.keys.first => ''}
        expect_create_error_with_model('course_module_element')
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for course_module_element_1' do
        put :update, id: course_module_element_1.id, course_module_element: valid_params
        expect_update_success_with_model('course_module_element', course_module_elements_url)
      end

      # optional
      it 'should respond OK to valid params for course_module_element_2' do
        put :update, id: course_module_element_2.id, course_module_element: valid_params
        expect_update_success_with_model('course_module_element', subject.course_module_special_link(course_module_1)) # deliberately 1 and not 2.
        expect(assigns(:course_module_element).id).to eq(course_module_element_2.id)
      end

      it 'should reject invalid params' do
        put :update, id: course_module_element_1.id, course_module_element: {valid_params.keys.first => ''}
        expect_update_error_with_model('course_module_element')
        expect(assigns(:course_module_element).id).to eq(course_module_element_1.id)
      end
    end

    describe "POST 'reorder'" do
      it 'should be OK with valid_array' do
        post :reorder, array_of_ids: [course_module_element_2.id, course_module_element_1.id]
        expect_reorder_success
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, id: course_module_element_1.id
        #expect_delete_success_with_model('course_module_element', course_module_elements_url)
        # todo replace the line above with the line below when course_module_elements have children
        expect_delete_error_with_model('course_module_element', course_module_elements_url)
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: course_module_element_3.id
        expect_delete_success_with_model('course_module_element', course_module_elements_url)
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
        post :create, course_module_element: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond ERROR not permitted' do
        put :update, id: 1, course_module_element: valid_params
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
        post :create, course_module_element: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond ERROR not permitted' do
        put :update, id: 1, course_module_element: valid_params
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
        post :create, course_module_element: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond ERROR not permitted' do
        put :update, id: 1, course_module_element: valid_params
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
        post :create, course_module_element: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond ERROR not permitted' do
        put :update, id: 1, course_module_element: valid_params
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
        post :create, course_module_element: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond ERROR not permitted' do
        put :update, id: 1, course_module_element: valid_params
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

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new, cm_id: course_module_1.id
        expect_new_success_with_model('course_module_element')
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with course_module_element_1' do
        get :edit, id: course_module_element_1.id
        expect_edit_success_with_model('course_module_element', course_module_element_1.id)
      end

      # optional
      it 'should respond OK with course_module_element_2' do
        get :edit, id: course_module_element_2.id
        expect_edit_success_with_model('course_module_element', course_module_element_2.id)
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, course_module_element: valid_params
        expect_create_success_with_model('course_module_element', edit_course_module_element_url(CourseModuleElement.last.id))
      end

      it 'should report error for invalid params' do
        post :create, course_module_element: {valid_params.keys.first => ''}
        expect_create_error_with_model('course_module_element')
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for course_module_element_1' do
        put :update, id: course_module_element_1.id, course_module_element: valid_params
        expect_update_success_with_model('course_module_element', course_module_elements_url)
      end

      # optional
      it 'should respond OK to valid params for course_module_element_2' do
        put :update, id: course_module_element_2.id, course_module_element: valid_params
        expect_update_success_with_model('course_module_element', course_module_elements_url)
        expect(assigns(:course_module_element).id).to eq(course_module_element_2.id)
      end

      it 'should reject invalid params' do
        put :update, id: course_module_element_1.id, course_module_element: {valid_params.keys.first => ''}
        expect_update_error_with_model('course_module_element')
        expect(assigns(:course_module_element).id).to eq(course_module_element_1.id)
      end
    end

    describe "POST 'reorder'" do
      it 'should be OK with valid_array' do
        post :reorder, array_of_ids: [course_module_element_2.id, course_module_element_1.id]
        expect_reorder_success
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, id: course_module_element_1.id
        #expect_delete_success_with_model('course_module_element', course_module_elements_url)
        # todo replace the line above with the line below when course_module_elements have children
        expect_delete_error_with_model('course_module_element', course_module_elements_url)
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: course_module_element_3.id
        expect_delete_success_with_model('course_module_element', course_module_elements_url)
      end
    end

  end

end
