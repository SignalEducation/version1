# == Schema Information
#
# Table name: subject_course_resources
#
#  id                       :integer          not null, primary key
#  name                     :string
#  subject_course_id        :integer
#  description              :text
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  file_upload_file_name    :string
#  file_upload_content_type :string
#  file_upload_file_size    :integer
#  file_upload_updated_at   :datetime
#

require 'rails_helper'
require 'support/users_and_groups_setup'

describe SubjectCourseResourcesController, type: :controller do

  include_context 'users_and_groups_setup'

  let!(:subject_course_resource_1) { FactoryGirl.create(:subject_course_resource) }
  let!(:subject_course_resource_2) { FactoryGirl.create(:subject_course_resource) }
  let!(:valid_params) { FactoryGirl.attributes_for(:subject_course_resource) }

  context 'Not logged in: ' do

    describe "GET 'index'" do
      it 'should redirect to sign_in' do
        get :index
        expect_bounce_as_not_signed_in
      end
    end

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

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      it 'should see subject_course_resource_1' do
        get :show, id: subject_course_resource_1.id
        expect_bounce_as_not_allowed
      end

      # optional - some other object
      it 'should see subject_course_resource_2' do
        get :show, id: subject_course_resource_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with subject_course_resource_1' do
        get :edit, id: subject_course_resource_1.id
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK with subject_course_resource_2' do
        get :edit, id: subject_course_resource_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, subject_course_resource: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should report error for invalid params' do
        post :create, subject_course_resource: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for subject_course_resource_1' do
        put :update, id: subject_course_resource_1.id, subject_course_resource: valid_params
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK to valid params for subject_course_resource_2' do
        put :update, id: subject_course_resource_2.id, subject_course_resource: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should reject invalid params' do
        put :update, id: subject_course_resource_1.id, subject_course_resource: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end


    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, id: subject_course_resource_1.id
        expect_bounce_as_not_allowed
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: subject_course_resource_2.id
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a complimentary_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(comp_user)
    end

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      it 'should see subject_course_resource_1' do
        get :show, id: subject_course_resource_1.id
        expect_bounce_as_not_allowed
      end

      # optional - some other object
      it 'should see subject_course_resource_2' do
        get :show, id: subject_course_resource_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with subject_course_resource_1' do
        get :edit, id: subject_course_resource_1.id
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK with subject_course_resource_2' do
        get :edit, id: subject_course_resource_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, subject_course_resource: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should report error for invalid params' do
        post :create, subject_course_resource: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for subject_course_resource_1' do
        put :update, id: subject_course_resource_1.id, subject_course_resource: valid_params
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK to valid params for subject_course_resource_2' do
        put :update, id: subject_course_resource_2.id, subject_course_resource: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should reject invalid params' do
        put :update, id: subject_course_resource_1.id, subject_course_resource: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end


    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, id: subject_course_resource_1.id
        expect_bounce_as_not_allowed
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: subject_course_resource_2.id
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a tutor_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(tutor_user)
    end

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      it 'should see subject_course_resource_1' do
        get :show, id: subject_course_resource_1.id
        expect_bounce_as_not_allowed
      end

      # optional - some other object
      it 'should see subject_course_resource_2' do
        get :show, id: subject_course_resource_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with subject_course_resource_1' do
        get :edit, id: subject_course_resource_1.id
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK with subject_course_resource_2' do
        get :edit, id: subject_course_resource_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, subject_course_resource: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should report error for invalid params' do
        post :create, subject_course_resource: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for subject_course_resource_1' do
        put :update, id: subject_course_resource_1.id, subject_course_resource: valid_params
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK to valid params for subject_course_resource_2' do
        put :update, id: subject_course_resource_2.id, subject_course_resource: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should reject invalid params' do
        put :update, id: subject_course_resource_1.id, subject_course_resource: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end


    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, id: subject_course_resource_1.id
        expect_bounce_as_not_allowed
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: subject_course_resource_2.id
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a blogger_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(blogger_user)
    end

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      it 'should see subject_course_resource_1' do
        get :show, id: subject_course_resource_1.id
        expect_bounce_as_not_allowed
      end

      # optional - some other object
      it 'should see subject_course_resource_2' do
        get :show, id: subject_course_resource_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with subject_course_resource_1' do
        get :edit, id: subject_course_resource_1.id
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK with subject_course_resource_2' do
        get :edit, id: subject_course_resource_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, subject_course_resource: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should report error for invalid params' do
        post :create, subject_course_resource: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for subject_course_resource_1' do
        put :update, id: subject_course_resource_1.id, subject_course_resource: valid_params
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK to valid params for subject_course_resource_2' do
        put :update, id: subject_course_resource_2.id, subject_course_resource: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should reject invalid params' do
        put :update, id: subject_course_resource_1.id, subject_course_resource: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end


    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, id: subject_course_resource_1.id
        expect_bounce_as_not_allowed
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: subject_course_resource_2.id
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a customer_support_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(customer_support_manager_user)
    end

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      it 'should see subject_course_resource_1' do
        get :show, id: subject_course_resource_1.id
        expect_bounce_as_not_allowed
      end

      # optional - some other object
      it 'should see subject_course_resource_2' do
        get :show, id: subject_course_resource_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with subject_course_resource_1' do
        get :edit, id: subject_course_resource_1.id
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK with subject_course_resource_2' do
        get :edit, id: subject_course_resource_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, subject_course_resource: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should report error for invalid params' do
        post :create, subject_course_resource: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for subject_course_resource_1' do
        put :update, id: subject_course_resource_1.id, subject_course_resource: valid_params
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK to valid params for subject_course_resource_2' do
        put :update, id: subject_course_resource_2.id, subject_course_resource: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should reject invalid params' do
        put :update, id: subject_course_resource_1.id, subject_course_resource: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end


    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, id: subject_course_resource_1.id
        expect_bounce_as_not_allowed
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: subject_course_resource_2.id
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a marketing_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(marketing_manager_user)
    end

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      it 'should see subject_course_resource_1' do
        get :show, id: subject_course_resource_1.id
        expect_bounce_as_not_allowed
      end

      # optional - some other object
      it 'should see subject_course_resource_2' do
        get :show, id: subject_course_resource_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with subject_course_resource_1' do
        get :edit, id: subject_course_resource_1.id
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK with subject_course_resource_2' do
        get :edit, id: subject_course_resource_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, subject_course_resource: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should report error for invalid params' do
        post :create, subject_course_resource: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for subject_course_resource_1' do
        put :update, id: subject_course_resource_1.id, subject_course_resource: valid_params
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK to valid params for subject_course_resource_2' do
        put :update, id: subject_course_resource_2.id, subject_course_resource: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should reject invalid params' do
        put :update, id: subject_course_resource_1.id, subject_course_resource: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end


    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, id: subject_course_resource_1.id
        expect_bounce_as_not_allowed
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: subject_course_resource_2.id
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a content_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(content_manager_user)
    end

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index
        expect_index_success_with_model('subject_course_resources', 2)
      end
    end

    describe "GET 'show/1'" do
      it 'should see subject_course_resource_1' do
        get :show, id: subject_course_resource_1.id
        expect_show_success_with_model('subject_course_resource', subject_course_resource_1.id)
      end

      # optional - some other object
      it 'should see subject_course_resource_2' do
        get :show, id: subject_course_resource_2.id
        expect_show_success_with_model('subject_course_resource', subject_course_resource_2.id)
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_new_success_with_model('subject_course_resource')
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with subject_course_resource_1' do
        get :edit, id: subject_course_resource_1.id
        expect_edit_success_with_model('subject_course_resource', subject_course_resource_1.id)
      end

      # optional
      it 'should respond OK with subject_course_resource_2' do
        get :edit, id: subject_course_resource_2.id
        expect_edit_success_with_model('subject_course_resource', subject_course_resource_2.id)
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, subject_course_resource: valid_params
        expect_create_success_with_model('subject_course_resource', subject_course_resources_url)
      end

      it 'should report error for invalid params' do
        post :create, subject_course_resource: {valid_params.keys.first => ''}
        expect_create_error_with_model('subject_course_resource')
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for subject_course_resource_1' do
        put :update, id: subject_course_resource_1.id, subject_course_resource: valid_params
        expect_update_success_with_model('subject_course_resource', subject_course_resources_url)
      end

      # optional
      it 'should respond OK to valid params for subject_course_resource_2' do
        put :update, id: subject_course_resource_2.id, subject_course_resource: valid_params
        expect_update_success_with_model('subject_course_resource', subject_course_resources_url)
        expect(assigns(:subject_course_resource).id).to eq(subject_course_resource_2.id)
      end

      it 'should reject invalid params' do
        put :update, id: subject_course_resource_1.id, subject_course_resource: {valid_params.keys.first => ''}
        expect_update_error_with_model('subject_course_resource')
        expect(assigns(:subject_course_resource).id).to eq(subject_course_resource_1.id)
      end
    end


    describe "DELETE 'destroy'" do
      it 'should be successfully deleted' do
        delete :destroy, id: subject_course_resource_1.id
        expect_delete_success_with_model('subject_course_resource', subject_course_resources_url)
      end
    end

  end

  context 'Logged in as a admin_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(admin_user)
    end

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index
        expect_index_success_with_model('subject_course_resources', 2)
      end
    end

    describe "GET 'show/1'" do
      it 'should see subject_course_resource_1' do
        get :show, id: subject_course_resource_1.id
        expect_show_success_with_model('subject_course_resource', subject_course_resource_1.id)
      end

      # optional - some other object
      it 'should see subject_course_resource_2' do
        get :show, id: subject_course_resource_2.id
        expect_show_success_with_model('subject_course_resource', subject_course_resource_2.id)
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_new_success_with_model('subject_course_resource')
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with subject_course_resource_1' do
        get :edit, id: subject_course_resource_1.id
        expect_edit_success_with_model('subject_course_resource', subject_course_resource_1.id)
      end

      # optional
      it 'should respond OK with subject_course_resource_2' do
        get :edit, id: subject_course_resource_2.id
        expect_edit_success_with_model('subject_course_resource', subject_course_resource_2.id)
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, subject_course_resource: valid_params
        expect_create_success_with_model('subject_course_resource', subject_course_resources_url)
      end

      it 'should report error for invalid params' do
        post :create, subject_course_resource: {valid_params.keys.first => ''}
        expect_create_error_with_model('subject_course_resource')
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for subject_course_resource_1' do
        put :update, id: subject_course_resource_1.id, subject_course_resource: valid_params
        expect_update_success_with_model('subject_course_resource', subject_course_resources_url)
      end

      # optional
      it 'should respond OK to valid params for subject_course_resource_2' do
        put :update, id: subject_course_resource_2.id, subject_course_resource: valid_params
        expect_update_success_with_model('subject_course_resource', subject_course_resources_url)
        expect(assigns(:subject_course_resource).id).to eq(subject_course_resource_2.id)
      end

      it 'should reject invalid params' do
        put :update, id: subject_course_resource_1.id, subject_course_resource: {valid_params.keys.first => ''}
        expect_update_error_with_model('subject_course_resource')
        expect(assigns(:subject_course_resource).id).to eq(subject_course_resource_1.id)
      end
    end


    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, id: subject_course_resource_1.id
        expect_delete_success_with_model('subject_course_resource', subject_course_resources_url)
      end
    end

  end

end
