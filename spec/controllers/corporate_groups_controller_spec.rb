# == Schema Information
#
# Table name: corporate_groups
#
#  id                    :integer          not null, primary key
#  corporate_customer_id :integer
#  name                  :string
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  corporate_manager_id  :integer
#

require 'rails_helper'
require 'support/users_and_groups_setup'

describe CorporateGroupsController, type: :controller do

  include_context 'users_and_groups_setup'

  let!(:corporation_1) { FactoryGirl.create(:corporate_customer) }
  let!(:corporation_2) { FactoryGirl.create(:corporate_customer) }
  let!(:corporation_1_groups) { [ FactoryGirl.create(:corporate_group, corporate_customer_id: corporation_1.id),
                              FactoryGirl.create(:corporate_group, corporate_customer_id: corporation_1.id) ] }
  let!(:corporation_2_groups) { [ FactoryGirl.create(:corporate_group, corporate_customer_id: corporation_2.id) ] }
  let!(:valid_params) { FactoryGirl.attributes_for(:corporate_group) }

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
      it 'should respond ERROR not permitted' do
        get :index
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
        get :edit, id: corporation_1_groups.first.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should respond ERROR not permitted' do
        post :create, corporate_group: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond ERROR not permitted' do
        put :update, id: corporation_1_groups.first.id, corporate_group: valid_params
        expect_bounce_as_not_allowed
      end
    end


    describe "DELETE 'destroy'" do
      it 'should respond ERROR not permitted' do
        delete :destroy, id: corporation_1_groups.first.id
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
      it 'should respond ERROR not permitted' do
        get :index
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
        get :edit, id: corporation_1_groups.first.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should respond ERROR not permitted' do
        post :create, corporate_group: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond ERROR not permitted' do
        put :update, id: corporation_1_groups.first.id, corporate_group: valid_params
        expect_bounce_as_not_allowed
      end
    end


    describe "DELETE 'destroy'" do
      it 'should respond ERROR not permitted' do
        delete :destroy, id: corporation_1_groups.first.id
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
      it 'should respond ERROR not permitted' do
        get :index
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
        get :edit, id: corporation_1_groups.first.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should respond ERROR not permitted' do
        post :create, corporate_group: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond ERROR not permitted' do
        put :update, id: corporation_1_groups.first.id, corporate_group: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "DELETE 'destroy'" do
      it 'should respond ERROR not permitted' do
        delete :destroy, id: corporation_1_groups.first.id
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
      it 'should respond ERROR not permitted' do
        get :index
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
        get :edit, id: corporation_1_groups.first.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should respond ERROR not permitted' do
        post :create, corporate_group: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond ERROR not permitted' do
        put :update, id: corporation_1_groups.first.id, corporate_group: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "DELETE 'destroy'" do
      it 'should respond ERROR not permitted' do
        delete :destroy, id: corporation_1_groups.first.id
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a corporate_customer_user: ' do

    before(:each) do
      activate_authlogic
      corporate_customer_user.update_attribute(:corporate_customer_id, corporation_1.id)
      UserSession.create!(corporate_customer_user)
    end

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index
        expect_index_success_with_model('corporate_groups', corporation_1_groups.length)
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_new_success_with_model('corporate_group')
        expect(assigns(:corporate_group).corporate_customer_id).to eq(corporate_customer_user.corporate_customer_id)
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with corporation_1_groups.first' do
        get :edit, id: corporation_1_groups.first.id
        expect_edit_success_with_model('corporate_group', corporation_1_groups.first.id)
      end

      # optional
      it 'should redirect to corporate groups index page for other corporation group' do
        get :edit, id: corporation_2_groups.first.id
        expect(response).to redirect_to(corporate_groups_url)
        expect(flash[:error]).to eq(I18n.t('controllers.application.you_are_not_permitted_to_do_that'))
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, corporate_group: valid_params.merge(corporate_customer_id: corporate_customer_user.corporate_customer_id)
        expect_create_success_with_model('corporate_group', corporate_groups_url)
      end

      it 'should report error for missing name' do
        post :create, corporate_group: valid_params.merge(corporate_customer_id: corporate_customer_user.corporate_customer_id, name: '')
        expect_create_error_with_model('corporate_group')
      end

      it 'should report error if corporation ids do not match' do
        post :create, corporate_group: valid_params.merge(corporate_customer_id: corporation_2.id)
        expect_create_error_with_model('corporate_group')
      end
    end

    describe "PUT 'update'" do
      it 'should respond OK to valid params for corporation_1_groups.first' do
        put :update, id: corporation_1_groups.first.id, corporate_group: { name: "Changed Corp 2 Group Name" }
        expect_update_success_with_model('corporate_group', corporate_groups_url)
      end

      # optional
      it 'should reject update if name is blank' do
        put :update, id: corporation_1_groups.first.id, corporate_group: { name: '' }
        expect_update_error_with_model('corporate_group')
        expect(assigns(:corporate_group).id).to eq(corporation_1_groups.first.id)
      end

      it 'should reject if corporation ids of group and current user do not match' do
        put :update, id: corporation_1_groups.first.id, corporate_group: { coprorate_customer_id: corporation_2.id }
        expect_update_error_with_model('corporate_group')
        expect(assigns(:corporate_group).id).to eq(corporation_1_groups.first.id)
      end
    end


    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        FactoryGirl.create(:corporate_group_grant, corporate_group_id: corporation_1_groups.first.id)
        delete :destroy, id: corporation_1_groups.first.id
        expect_delete_error_with_model('corporate_group', corporate_groups_url)
      end

      it 'should be ERROR if corporation ids of group and current user do not match' do
        delete :destroy, id: corporation_2_groups.first.id
        expect_delete_error_with_model('corporate_group', corporate_groups_url)
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: corporation_1_groups.last.id
        expect_delete_success_with_model('corporate_group', corporate_groups_url)
      end
    end

  end

  context 'Logged in as a blogger_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(blogger_user)
    end

    describe "GET 'index'" do
      it 'should respond ERROR not permitted' do
        get :index
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
        get :edit, id: corporation_1_groups.first.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should respond ERROR not permitted' do
        post :create, corporate_group: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond ERROR not permitted' do
        put :update, id: corporation_1_groups.first.id, corporate_group: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "DELETE 'destroy'" do
      it 'should respond ERROR not permitted' do
        delete :destroy, id: corporation_1_groups.first.id
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
      it 'should respond ERROR not permitted' do
        get :index
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
        get :edit, id: corporation_1_groups.first.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should respond ERROR not permitted' do
        post :create, corporate_group: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond ERROR not permitted' do
        put :update, id: corporation_1_groups.first.id, corporate_group: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "DELETE 'destroy'" do
      it 'should respond ERROR not permitted' do
        delete :destroy, id: corporation_1_groups.first.id
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
      it 'should respond ERROR not permitted' do
        get :index
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
        get :edit, id: corporation_1_groups.first.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should respond ERROR not permitted' do
        post :create, corporate_group: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond ERROR not permitted' do
        put :update, id: corporation_1_groups.first.id, corporate_group: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "DELETE 'destroy'" do
      it 'should respond ERROR not permitted' do
        delete :destroy, id: corporation_1_groups.first.id
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
      it 'should respond ERROR not permitted' do
        get :index
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
        get :edit, id: corporation_1_groups.first.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should respond ERROR not permitted' do
        post :create, corporate_group: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond ERROR not permitted' do
        put :update, id: corporation_1_groups.first.id, corporate_group: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "DELETE 'destroy'" do
      it 'should respond ERROR not permitted' do
        delete :destroy, id: corporation_1_groups.first.id
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
        expect_index_success_with_model('corporate_groups', corporation_1_groups.length + corporation_2_groups.length)
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_new_success_with_model('corporate_group')
      end
    end

    describe "GET 'edit'" do
      it 'should respond OK with corporation_1_groups.first' do
        get :edit, id: corporation_1_groups.first.id
        expect_edit_success_with_model('corporate_group', corporation_1_groups.first.id)
      end

      # optional
      it 'should respond OK with corporation_2_groups.first' do
        get :edit, id: corporation_2_groups.first.id
        expect_edit_success_with_model('corporate_group', corporation_2_groups.first.id)
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, corporate_group: valid_params
        expect_create_success_with_model('corporate_group', corporate_groups_url)
      end

      it 'should report error for missing corporation id' do
        post :create, corporate_group: valid_params.merge(corporate_customer_id: nil)
        expect_create_error_with_model('corporate_group')
      end

      it 'should report error for missing group name' do
        post :create, corporate_group: valid_params.merge(name: '')
        expect_create_error_with_model('corporate_group')
      end
    end

    describe "PUT 'update'" do
      it 'should respond OK to valid params for corporation_1_groups.first' do
        valid_params.delete(:corporate_customer_id)
        put :update, id: corporation_1_groups.first.id, corporate_group: valid_params
        expect_update_success_with_model('corporate_group', corporate_groups_url)
      end

      # optional
      it 'should respond OK to valid params for corporation_2_groups.first' do
        valid_params.delete(:corporate_customer_id)
        put :update, id: corporation_2_groups.first.id, corporate_group: valid_params
        expect_update_success_with_model('corporate_group', corporate_groups_url)
      end

      it 'should reject if name is missing' do
        put :update, id: corporation_1_groups.first.id, corporate_group: valid_params.merge(name: '')
        expect_update_error_with_model('corporate_group')
        expect(assigns(:corporate_group).id).to eq(corporation_1_groups.first.id)
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        FactoryGirl.create(:corporate_group_grant, corporate_group_id: corporation_1_groups.first.id)
        delete :destroy, id: corporation_1_groups.first.id
        expect_delete_error_with_model('corporate_group', corporate_groups_url)
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: corporation_1_groups.first.id
        expect_delete_success_with_model('corporate_group', corporate_groups_url)
      end
    end

  end

end
