# == Schema Information
#
# Table name: groups
#
#  id                            :integer          not null, primary key
#  name                          :string
#  name_url                      :string
#  active                        :boolean          default(FALSE), not null
#  sorting_order                 :integer
#  description                   :text
#  subject_id                    :integer
#  created_at                    :datetime         not null
#  updated_at                    :datetime         not null
#  corporate_customer_id         :integer
#  destroyed_at                  :datetime
#  image_file_name               :string
#  image_content_type            :string
#  image_file_size               :integer
#  image_updated_at              :datetime
#  background_colour             :string
#  background_image_file_name    :string
#  background_image_content_type :string
#  background_image_file_size    :integer
#  background_image_updated_at   :datetime
#

require 'rails_helper'
require 'support/users_and_groups_setup'
require 'support/course_content'

describe GroupsController, type: :controller do

  include_context 'users_and_groups_setup'
  include_context 'course_content'

  let!(:group_1) { FactoryGirl.create(:group) }
  let!(:group_2) { FactoryGirl.create(:group) }
  let!(:group_1_subject_course) { [ FactoryGirl.create(:active_subject_course),
                                    FactoryGirl.create(:active_subject_course) ] }
  let!(:valid_params) { FactoryGirl.attributes_for(:group) }

  context 'Not logged in: ' do

    describe "GET 'index'" do
      it 'should redirect to sign_in' do
        get :index
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

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index
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
      it 'should respond OK with group_1' do
        get :edit, id: group_1.id
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK with group_2' do
        get :edit, id: group_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, group: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should report error for invalid params' do
        post :create, group: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for group_1' do
        put :update, id: group_1.id, group: valid_params
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK to valid params for group_2' do
        put :update, id: group_2.id, group: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should reject invalid params' do
        put :update, id: group_1.id, group: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'reorder'" do
      it 'should be OK with valid_array' do
        post :reorder, array_of_ids: [group_2.id, group_1.id]
        expect_bounce_as_not_allowed
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, id: group_1.id
        expect_bounce_as_not_allowed
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: group_2.id
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

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with group_1' do
        get :edit, id: group_1.id
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK with group_2' do
        get :edit, id: group_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, group: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should report error for invalid params' do
        post :create, group: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for group_1' do
        put :update, id: group_1.id, group: valid_params
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK to valid params for group_2' do
        put :update, id: group_2.id, group: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should reject invalid params' do
        put :update, id: group_1.id, group: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'reorder'" do
      it 'should be OK with valid_array' do
        post :reorder, array_of_ids: [group_2.id, group_1.id]
        expect_bounce_as_not_allowed
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, id: group_1.id
        expect_bounce_as_not_allowed
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: group_2.id
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

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with group_1' do
        get :edit, id: group_1.id
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK with group_2' do
        get :edit, id: group_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, group: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should report error for invalid params' do
        post :create, group: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for group_1' do
        put :update, id: group_1.id, group: valid_params
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK to valid params for group_2' do
        put :update, id: group_2.id, group: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should reject invalid params' do
        put :update, id: group_1.id, group: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'reorder'" do
      it 'should be OK with valid_array' do
        post :reorder, array_of_ids: [group_2.id, group_1.id]
        expect_bounce_as_not_allowed
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, id: group_1.id
        expect_bounce_as_not_allowed
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: group_2.id
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a corporate_student_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(corporate_student_user)
    end

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index
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
      it 'should respond OK with group_1' do
        get :edit, id: group_1.id
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK with group_2' do
        get :edit, id: group_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, group: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should report error for invalid params' do
        post :create, group: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for group_1' do
        put :update, id: group_1.id, group: valid_params
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK to valid params for group_2' do
        put :update, id: group_2.id, group: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should reject invalid params' do
        put :update, id: group_1.id, group: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'reorder'" do
      it 'should be OK with valid_array' do
        post :reorder, array_of_ids: [group_2.id, group_1.id]
        expect_bounce_as_not_allowed
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, id: group_1.id
        expect_bounce_as_not_allowed
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: group_2.id
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a corporate_customer_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(corporate_customer_user)
    end

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index
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
      it 'should respond OK with group_1' do
        get :edit, id: group_1.id
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK with group_2' do
        get :edit, id: group_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, group: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should report error for invalid params' do
        post :create, group: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for group_1' do
        put :update, id: group_1.id, group: valid_params
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK to valid params for group_2' do
        put :update, id: group_2.id, group: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should reject invalid params' do
        put :update, id: group_1.id, group: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'reorder'" do
      it 'should be OK with valid_array' do
        post :reorder, array_of_ids: [group_2.id, group_1.id]
        expect_bounce_as_not_allowed
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be OK as no dependencies exist' do
        delete :destroy, id: group_2.id
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

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with group_1' do
        get :edit, id: group_1.id
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK with group_2' do
        get :edit, id: group_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, group: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should report error for invalid params' do
        post :create, group: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for group_1' do
        put :update, id: group_1.id, group: valid_params
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK to valid params for group_2' do
        put :update, id: group_2.id, group: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should reject invalid params' do
        put :update, id: group_1.id, group: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'reorder'" do
      it 'should be OK with valid_array' do
        post :reorder, array_of_ids: [group_2.id, group_1.id]
        expect_bounce_as_not_allowed
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, id: group_1.id
        expect_bounce_as_not_allowed
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: group_2.id
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
        expect_index_success_with_model('groups', 4)
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_new_success_with_model('group')
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with group_1' do
        get :edit, id: group_1.id
        expect_edit_success_with_model('group', group_1.id)
      end

      # optional
      it 'should respond OK with group_2' do
        get :edit, id: group_2.id
        expect_edit_success_with_model('group', group_2.id)
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, group: valid_params
        expect_create_success_with_model('group', groups_url)
      end

      it 'should report error for invalid params' do
        post :create, group: {valid_params.keys.first => ''}
        expect_create_error_with_model('group')
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for group_1' do
        put :update, id: group_1.id, group: valid_params
        expect_update_success_with_model('group', groups_url)
      end

      # optional
      it 'should respond OK to valid params for group_2' do
        put :update, id: group_2.id, group: valid_params
        expect_update_success_with_model('group', groups_url)
        expect(assigns(:group).id).to eq(group_2.id)
      end

      it 'should reject invalid params' do
        put :update, id: group_1.id, group: {valid_params.keys.first => ''}
        expect_update_error_with_model('group')
        expect(assigns(:group).id).to eq(group_1.id)
      end
    end

    describe "POST 'reorder'" do
      it 'should be OK with valid_array' do
        post :reorder, array_of_ids: [group_2.id, group_1.id]
        expect_reorder_success
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be OK as no dependencies exist' do
        delete :destroy, id: group_2.id
        expect_delete_success_with_model('group', groups_url)
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

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with group_1' do
        get :edit, id: group_1.id
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK with group_2' do
        get :edit, id: group_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, group: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should report error for invalid params' do
        post :create, group: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for group_1' do
        put :update, id: group_1.id, group: valid_params
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK to valid params for group_2' do
        put :update, id: group_2.id, group: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should reject invalid params' do
        put :update, id: group_1.id, group: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'reorder'" do
      it 'should be OK with valid_array' do
        post :reorder, array_of_ids: [group_2.id, group_1.id]
        expect_bounce_as_not_allowed
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, id: group_1.id
        expect_bounce_as_not_allowed
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: group_2.id
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

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with group_1' do
        get :edit, id: group_1.id
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK with group_2' do
        get :edit, id: group_2.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, group: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should report error for invalid params' do
        post :create, group: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for group_1' do
        put :update, id: group_1.id, group: valid_params
        expect_bounce_as_not_allowed
      end

      # optional
      it 'should respond OK to valid params for group_2' do
        put :update, id: group_2.id, group: valid_params
        expect_bounce_as_not_allowed
      end

      it 'should reject invalid params' do
        put :update, id: group_1.id, group: {valid_params.keys.first => ''}
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'reorder'" do
      it 'should be OK with valid_array' do
        post :reorder, array_of_ids: [group_2.id, group_1.id]
        expect_bounce_as_not_allowed
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, id: group_1.id
        expect_bounce_as_not_allowed
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: group_2.id
        expect_bounce_as_not_allowed
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
        expect_index_success_with_model('groups', 4)
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_new_success_with_model('group')
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with group_1' do
        get :edit, id: group_1.id
        expect_edit_success_with_model('group', group_1.id)
      end

      # optional
      it 'should respond OK with group_2' do
        get :edit, id: group_2.id
        expect_edit_success_with_model('group', group_2.id)
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, group: valid_params
        expect_create_success_with_model('group', groups_url)
      end

      it 'should report error for invalid params' do
        post :create, group: {valid_params.keys.first => ''}
        expect_create_error_with_model('group')
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for group_1' do
        put :update, id: group_1.id, group: valid_params
        expect_update_success_with_model('group', groups_url)
      end

      # optional
      it 'should respond OK to valid params for group_2' do
        put :update, id: group_2.id, group: valid_params
        expect_update_success_with_model('group', groups_url)
        expect(assigns(:group).id).to eq(group_2.id)
      end

      it 'should reject invalid params' do
        put :update, id: group_1.id, group: {valid_params.keys.first => ''}
        expect_update_error_with_model('group')
        expect(assigns(:group).id).to eq(group_1.id)
      end
    end

    describe "POST 'reorder'" do
      it 'should be OK with valid_array' do
        post :reorder, array_of_ids: [group_2.id, group_1.id]
        expect_reorder_success
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be OK as no dependencies exist' do
        delete :destroy, id: group_2.id
        expect_delete_success_with_model('group', groups_url)
      end
    end

  end

end
