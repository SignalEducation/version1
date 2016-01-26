# == Schema Information
#
# Table name: user_groups
#
#  id                                   :integer          not null, primary key
#  name                                 :string
#  description                          :text
#  individual_student                   :boolean          default(FALSE), not null
#  corporate_student                    :boolean          default(FALSE), not null
#  tutor                                :boolean          default(FALSE), not null
#  content_manager                      :boolean          default(FALSE), not null
#  blogger                              :boolean          default(FALSE), not null
#  corporate_customer                   :boolean          default(FALSE), not null
#  site_admin                           :boolean          default(FALSE), not null
#  forum_manager                        :boolean          default(FALSE), not null
#  subscription_required_at_sign_up     :boolean          default(FALSE), not null
#  subscription_required_to_see_content :boolean          default(FALSE), not null
#  created_at                           :datetime
#  updated_at                           :datetime
#

require 'rails_helper'
require 'support/users_and_groups_setup'

describe UserGroupsController, type: :controller do

  include_context 'users_and_groups_setup'

  let!(:valid_params) { FactoryGirl.attributes_for(:user_group) }

  context 'Not logged in...' do

    describe "GET 'index'" do
      it 'should redirect to root' do
        get :index
        expect_bounce_as_not_signed_in
      end
    end

    describe "GET 'show/1'" do
      it 'should redirect to root' do
        get :show, id: 1
        expect_bounce_as_not_signed_in
      end
    end

    describe "GET 'new'" do
      it 'should redirect to root' do
        get :new
        expect_bounce_as_not_signed_in
      end
    end

    describe "GET 'edit/1'" do
      it 'should redirect to root' do
        get :edit, id: 1
        expect_bounce_as_not_signed_in
      end
    end

    describe "POST 'create'" do
      it 'should redirect to root' do
        post :create, user_group: valid_params
        expect_bounce_as_not_signed_in
      end
    end

    describe "PUT 'update/1'" do
      it 'should redirect to root' do
        put :update, id: 1, user_group: valid_params
        expect_bounce_as_not_signed_in
      end
    end

    describe "DELETE 'destroy'" do
      it 'should redirect to root' do
        delete :destroy, id: 1
        expect_bounce_as_not_signed_in
      end
    end

  end

  context 'Logged in as a individual_student_user' do

    before(:each) do
      activate_authlogic
      UserSession.create!(individual_student_user)
    end

    describe "GET 'index'" do
      it 'should redirect to root' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      it 'should redirect to root' do
        get :show, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      it 'should redirect to root' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should redirect to root' do
        get :edit, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should redirect to root' do
        post :create, user_group: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should redirect to root' do
        put :update, id: 1, user_group: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "DELETE 'destroy'" do
      it 'should redirect to root' do
        delete :destroy, id: 1
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a corporate_student_user' do

    before(:each) do
      activate_authlogic
      UserSession.create!(corporate_student_user)
    end

    describe "GET 'index'" do
      it 'should redirect to root' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      it 'should redirect to root' do
        get :show, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      it 'should redirect to root' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should redirect to root' do
        get :edit, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should redirect to root' do
        post :create, user_group: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should redirect to root' do
        put :update, id: 1, user_group: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "DELETE 'destroy'" do
      it 'should redirect to root' do
        delete :destroy, id: 1
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a tutor_user' do

    before(:each) do
      activate_authlogic
      UserSession.create!(tutor_user)
    end

    describe "GET 'index'" do
      it 'should redirect to root' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      it 'should redirect to root' do
        get :show, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      it 'should redirect to root' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should redirect to root' do
        get :edit, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should redirect to root' do
        post :create, user_group: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should redirect to root' do
        put :update, id: 1, user_group: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "DELETE 'destroy'" do
      it 'should redirect to root' do
        delete :destroy, id: 1
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a corporate_customer_user' do

    before(:each) do
      activate_authlogic
      UserSession.create!(corporate_customer_user)
    end

    describe "GET 'index'" do
      it 'should redirect to root' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      it 'should redirect to root' do
        get :show, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      it 'should redirect to root' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should redirect to root' do
        get :edit, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should redirect to root' do
        post :create, user_group: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should redirect to root' do
        put :update, id: 1, user_group: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "DELETE 'destroy'" do
      it 'should redirect to root' do
        delete :destroy, id: 1
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a blogger_user' do

    before(:each) do
      activate_authlogic
      UserSession.create!(blogger_user)
    end

    describe "GET 'index'" do
      it 'should redirect to root' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      it 'should redirect to root' do
        get :show, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      it 'should redirect to root' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should redirect to root' do
        get :edit, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should redirect to root' do
        post :create, user_group: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should redirect to root' do
        put :update, id: 1, user_group: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "DELETE 'destroy'" do
      it 'should redirect to root' do
        delete :destroy, id: 1
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a forum_manager_user' do

    before(:each) do
      activate_authlogic
      UserSession.create!(forum_manager_user)
    end

    describe "GET 'index'" do
      it 'should redirect to root' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      it 'should redirect to root' do
        get :show, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      it 'should redirect to root' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should redirect to root' do
        get :edit, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should redirect to root' do
        post :create, user_group: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should redirect to root' do
        put :update, id: 1, user_group: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "DELETE 'destroy'" do
      it 'should redirect to root' do
        delete :destroy, id: 1
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a content_manager_user' do

    before(:each) do
      activate_authlogic
      UserSession.create!(content_manager_user)
    end

    describe "GET 'index'" do
      it 'should redirect to root' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      it 'should redirect to root' do
        get :show, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      it 'should redirect to root' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should redirect to root' do
        get :edit, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should redirect to root' do
        post :create, user_group: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should redirect to root' do
        put :update, id: 1, user_group: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "DELETE 'destroy'" do
      it 'should redirect to root' do
        delete :destroy, id: 1
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a admin_user' do

    before(:each) do
      activate_authlogic
      UserSession.create!(admin_user)
    end

    describe "GET 'index'" do
      it 'should respond with OK' do
        get :index
        expect_index_success_with_model('user_groups', UserGroup.all.count)
      end
    end

    describe "GET 'show/1'" do
      it 'should respond with OK' do
        get :show, id: individual_student_user_group.id
        expect_show_success_with_model('user_group', individual_student_user_group.id)
      end

        it 'should respond with OK if I ask for another' do
        get :show, id: site_admin_user_group.id
        expect_show_success_with_model('user_group', site_admin_user_group.id)
      end
    end

    describe "GET 'new'" do
      it 'should respond with OK' do
        get :new
        expect_new_success_with_model('user_group')
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond with OK' do
        get :edit, id: individual_student_user_group.id
        expect_edit_success_with_model('user_group', individual_student_user_group.id)
        end

      it 'should respond with OK' do
        get :edit, id: site_admin_user_group.id
        expect_edit_success_with_model('user_group', site_admin_user_group.id)
      end
    end

    describe "POST 'create'" do
      it 'should respond with OK to good input' do
        post :create, user_group: valid_params
        expect_create_success_with_model('user_group', user_groups_url)
      end

      it 'should reload the form for bad input' do
        post :create, user_group: {name: '', description: ''}
        expect_create_error_with_model('user_group')
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid input' do
        put :update, id: individual_student_user_group.id, user_group: valid_params
        expect_update_success_with_model('user_group', user_groups_url)
      end

      it 'should reload the edit page on invalid input' do
        put :update, id: individual_student_user_group.id, user_group: {name: ''}
        expect_update_error_with_model('user_group')
      end
    end

    describe "DELETE 'destroy'" do
      it 'should allow the deletion as dependant has been deleted too' do
        individual_student_user_group.users.destroy_all
        delete :destroy, id: individual_student_user_group.id
        expect_delete_success_with_model('user_group', user_groups_url)
      end

      it 'should fail to delete as dependant exists' do
        x = individual_student_user
        delete :destroy, id: individual_student_user_group.id
        expect_delete_error_with_model('user_group', user_groups_url)
      end
    end

  end

end
