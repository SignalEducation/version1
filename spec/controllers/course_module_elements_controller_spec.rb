# == Schema Information
#
# Table name: course_module_elements
#
#  id                        :integer          not null, primary key
#  name                      :string
#  name_url                  :string
#  description               :text
#  estimated_time_in_seconds :integer
#  course_module_id          :integer
#  sorting_order             :integer
#  related_quiz_id           :integer
#  related_video_id          :integer
#  created_at                :datetime
#  updated_at                :datetime
#  is_video                  :boolean          default(FALSE), not null
#  is_quiz                   :boolean          default(FALSE), not null
#  active                    :boolean          default(TRUE), not null
#  seo_description           :string
#  seo_no_index              :boolean          default(FALSE)
#  destroyed_at              :datetime
#  number_of_questions       :integer          default(0)
#  duration                  :float            default(0.0)
#

require 'rails_helper'
require 'support/users_and_groups_setup'
require 'support/course_content'

describe CourseModuleElementsController, type: :controller do

  include_context 'users_and_groups_setup'
  include_context 'course_content'

  let!(:valid_params) { course_module_element_1_1.attributes.merge({name: 'ABCDE', name_url: 'adcbw'}) }

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

  context 'Logged in as a complimentary_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(comp_user)
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
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with course_module_element_1' do
        get :edit, id: course_module_element_2_1.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, course_module_element: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should report error for invalid params' do
        post :create, course_module_element: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for course_module_element_1' do
        put :update, id: course_module_element_1_1.id, course_module_element: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should reject invalid params' do
        put :update, id: course_module_element_1_1.id, course_module_element: {name_url: ''}
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'reorder'" do
      it 'should be OK with valid_array' do
        post :reorder, array_of_ids: [course_module_element_2_1.id, course_module_element_2_2.id]
        expect_bounce_as_not_allowed
      end
    end

    describe "DELETE 'destroy'" do

      before(:each) do
        x = course_module_element_quiz_1_1.id
      end

      describe "DELETE 'destroy'" do
        it 'should be OK as no dependencies exist' do
          #course_module_element_2_2
          delete :destroy, id: course_module_element_2_2.id
          expect_bounce_as_not_allowed
        end
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
        get :new, cm_id: course_module_1.id
        expect_new_success_with_model('course_module_element')
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with course_module_element_1_1 - quiz' do
        get :edit, id: course_module_element_1_1.id
        expect_edit_success_with_model('course_module_element', course_module_element_1_1.id)
      end

      # optional
      it 'should respond OK with course_module_element_1_2 - video' do
        get :edit, id: course_module_element_1_2.id
        expect_edit_success_with_model('course_module_element', course_module_element_1_2.id)
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, course_module_element: valid_params
        expect_create_success_with_model('course_module_element', subject.course_module_special_link(course_module_1))
      end

      it 'should report error for invalid params' do
        post :create, course_module_element: {valid_params.keys.first => ''}
        expect_create_error_with_model('course_module_element')
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for course_module_element_1_1' do
        put :update, id: course_module_element_1_1.id, course_module_element: valid_params
        expect_update_success_with_model('course_module_element', subject.course_module_special_link(course_module_1))
      end

      # optional
      it 'should respond OK to valid params for course_module_element_1_2' do
        put :update, id: course_module_element_1_2.id, course_module_element: valid_params
        expect_update_success_with_model('course_module_element', subject.course_module_special_link(course_module_1))
        expect(assigns(:course_module_element).id).to eq(course_module_element_1_2.id)
      end

      it 'should reject invalid params' do
        put :update, id: course_module_element_1_1.id, course_module_element: {name_url: ''}
        expect_update_error_with_model('course_module_element')
        expect(assigns(:course_module_element).id).to eq(course_module_element_1_1.id)
      end
    end

    describe "POST 'reorder'" do
      it 'should be OK with valid_array' do
        post :reorder, array_of_ids: [course_module_element_2_1.id, course_module_element_2_2.id]
        expect_reorder_success
      end
    end

    describe "DELETE 'destroy'" do

      before(:each) do
        x = course_module_element_quiz_1_1.id
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: course_module_element_2_2.id
        expect_delete_success_with_model('course_module_element', subject.course_module_special_link(course_module_element_2_2.course_module))
      end
    end

  end

  context 'Logged in as a customer_support_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(customer_support_manager_user)
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

  context 'Logged in as a marketing_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(marketing_manager_user)
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
      it 'should respond OK with course_module_element_1_1 - quiz' do
        get :edit, id: course_module_element_1_1.id
        expect_edit_success_with_model('course_module_element', course_module_element_1_1.id)
      end

      # optional
      it 'should respond OK with course_module_element_1_2 - video' do
        get :edit, id: course_module_element_1_2.id
        expect_edit_success_with_model('course_module_element', course_module_element_1_2.id)
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, course_module_element: valid_params
        expect_create_success_with_model('course_module_element', subject.course_module_special_link(course_module_1))
      end

      it 'should report error for invalid params' do
        post :create, course_module_element: {valid_params.keys.first => ''}
        expect_create_error_with_model('course_module_element')
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for course_module_element_1_1' do
        put :update, id: course_module_element_1_1.id, course_module_element: valid_params
        expect_update_success_with_model('course_module_element', subject.course_module_special_link(course_module_1))
      end

      # optional
      it 'should respond OK to valid params for course_module_element_1_2' do
        put :update, id: course_module_element_1_2.id, course_module_element: valid_params
        expect_update_success_with_model('course_module_element', subject.course_module_special_link(course_module_1))
        expect(assigns(:course_module_element).id).to eq(course_module_element_1_2.id)
      end

      it 'should reject invalid params' do
        put :update, id: course_module_element_1_1.id, course_module_element: {name_url: ''}
        expect_update_error_with_model('course_module_element')
        expect(assigns(:course_module_element).id).to eq(course_module_element_1_1.id)
      end
    end

    describe "POST 'reorder'" do
      it 'should be OK with valid_array' do
        post :reorder, array_of_ids: [course_module_element_2_1.id, course_module_element_2_2.id]
        expect_reorder_success
      end
    end

    describe "DELETE 'destroy'" do

      before(:each) do
        x = course_module_element_quiz_1_1.id
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: course_module_element_2_2.id
        expect_delete_success_with_model('course_module_element', subject.course_module_special_link(course_module_element_2_2.course_module))
      end
    end

  end

end
