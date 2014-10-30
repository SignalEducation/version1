require 'rails_helper'
require 'support/users_and_groups_setup'

describe UsersController, type: :controller do

  include_context 'users_and_groups_setup'

  let!(:valid_params) { FactoryGirl.attributes_for(:individual_student_user) }

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
        post :create, user: valid_params
        expect_bounce_as_not_signed_in
      end
    end

    describe "PUT 'update/1'" do
      it 'should redirect to root' do
        put :update, id: 1, user: valid_params
        expect_bounce_as_not_signed_in
      end
    end

    describe "DELETE 'destroy'" do
      it 'should redirect to root' do
        delete :destroy, id: 1
        expect_bounce_as_not_signed_in
      end
    end

    describe "POST 'change_password'" do
      it 'should redirect to root' do
        post :change_password
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
      it 'should see my own profile' do
        get :show, id: individual_student_user.id
        expect_show_success_with_model('user', individual_student_user.id)
      end

      it 'should see my own profile even if I ask for another' do
        get :show, id: admin_user.id
        expect_show_success_with_model('user', individual_student_user.id)
      end
    end

    describe "GET 'new'" do
      it 'should redirect to root' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond with OK' do
        get :edit, id: individual_student_user.id
        expect_edit_success_with_model('user', individual_student_user.id)
      end

      it 'should only allow editing of own user' do
        get :edit, id: admin_user.id
        expect_edit_success_with_model('user', individual_student_user.id)
      end
    end

    describe "POST 'create'" do
      it 'should redirect to root' do
        post :create, user: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params' do
        put :update, id: individual_student_user.id, user: valid_params
        expect_update_success_with_model('user', profile_url)
        expect(assigns(:user).id).to eq(individual_student_user.id)
      end

      it 'should respond OK to valid params and insist on their own user ID being updated' do
        put :update, id: admin_user.id, user: valid_params
        expect_update_success_with_model('user', profile_url)
        expect(assigns(:user).id).to eq(individual_student_user.id)
      end

      it 'should reject invalid params' do
        put :update, id: individual_student_user.id, user: {email: 'a'}
        expect_update_error_with_model('user')
      end
    end

    describe "DELETE 'destroy'" do
      it 'should redirect to root' do
        delete :destroy, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "POST: 'change_password'" do
      it 'should respond OK to correct details' do
        post :change_password, user: {current_password: 'letSomeone1n', password: '456456456', password_confirmation: '456456456'}
        expect_change_password_success_with_model(profile_url)
      end

      it 'should respond ERROR to incorrect details' do
        post :change_password, user: {current_password: 'oops', password: '456456456', password_confirmation: '456456456'}
        expect_change_password_error_with_model(profile_url)
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
      it 'should see my own profile' do
        get :show, id: corporate_student_user.id
        expect_show_success_with_model('user', corporate_student_user.id)
      end

      it 'should see my own profile even if I ask for another' do
        get :show, id: admin_user.id
        expect_show_success_with_model('user', corporate_student_user.id)
      end
    end

    describe "GET 'new'" do
      it 'should redirect to root' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond with OK' do
        get :edit, id: corporate_student_user.id
        expect_edit_success_with_model('user', corporate_student_user.id)
      end

      it 'should only allow editing of own user' do
        get :edit, id: admin_user.id
        expect_edit_success_with_model('user', corporate_student_user.id)
      end
    end

    describe "POST 'create'" do
      it 'should redirect to root' do
        post :create, user: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params' do
        put :update, id: corporate_student_user.id, user: valid_params
        expect_update_success_with_model('user', profile_url)
        expect(assigns(:user).id).to eq(corporate_student_user.id)
      end

      it 'should respond OK to valid params and insist on their own user ID being updated' do
        put :update, id: admin_user.id, user: valid_params
        expect_update_success_with_model('user', profile_url)
        expect(assigns(:user).id).to eq(corporate_student_user.id)
      end

      it 'should reject invalid params' do
        put :update, id: corporate_student_user.id, user: {email: 'a'}
        expect_update_error_with_model('user')
        expect(assigns(:user).id).to eq(corporate_student_user.id)
      end
    end

    describe "DELETE 'destroy'" do
      it 'should redirect to root' do
        delete :destroy, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "POST: 'change_password'" do
      it 'should respond OK to correct details' do
        post :change_password, user: {current_password: 'letSomeone1n', password: '456456456', password_confirmation: '456456456'}
        expect_change_password_success_with_model(profile_url)
      end

      it 'should respond ERROR to incorrect details' do
        post :change_password, user: {current_password: 'oops', password: '456456456', password_confirmation: '456456456'}
        expect_change_password_error_with_model(profile_url)
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
      it 'should see my own profile' do
        get :show, id: tutor_user.id
        expect_show_success_with_model('user', tutor_user.id)
      end

      it 'should see my own profile even if I ask for another' do
        get :show, id: admin_user.id
        expect_show_success_with_model('user', tutor_user.id)
      end
    end

    describe "GET 'new'" do
      it 'should redirect to root' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond with OK' do
        get :edit, id: tutor_user.id
        expect_edit_success_with_model('user', tutor_user.id)
      end

      it 'should only allow editing of own user' do
        get :edit, id: admin_user.id
        expect_edit_success_with_model('user', tutor_user.id)
      end
    end

    describe "POST 'create'" do
      it 'should redirect to root' do
        post :create, user: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params' do
        put :update, id: tutor_user.id, user: valid_params
        expect_update_success_with_model('user', profile_url)
        expect(assigns(:user).id).to eq(tutor_user.id)
      end

      it 'should respond OK to valid params and insist on their own user ID being updated' do
        put :update, id: admin_user.id, user: valid_params
        expect_update_success_with_model('user', profile_url)
        expect(assigns(:user).id).to eq(tutor_user.id)
      end

      it 'should reject invalid params' do
        put :update, id: tutor_user.id, user: {email: 'a'}
        expect_update_error_with_model('user')
        expect(assigns(:user).id).to eq(tutor_user.id)
      end
    end

    describe "DELETE 'destroy'" do
      it 'should redirect to root' do
        delete :destroy, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "POST: 'change_password'" do
      it 'should respond OK to correct details' do
        post :change_password, user: {current_password: 'letSomeone1n', password: '456456456', password_confirmation: '456456456'}
        expect_change_password_success_with_model(profile_url)
      end

      it 'should respond ERROR to incorrect details' do
        post :change_password, user: {current_password: 'oops', password: '456456456', password_confirmation: '456456456'}
        expect_change_password_error_with_model(profile_url)
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
      it 'should see my own profile' do
        get :show, id: corporate_customer_user.id
        expect_show_success_with_model('user',corporate_customer_user.id)
      end

      it 'should see my own profile even if I ask for another' do
        get :show, id: admin_user.id
        expect_show_success_with_model('user',corporate_customer_user.id)
      end
    end

    describe "GET 'new'" do
      it 'should redirect to root' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond with OK' do
        get :edit, id: corporate_customer_user.id
        expect_edit_success_with_model('user',corporate_customer_user.id)
      end

      it 'should only allow editing of own user' do
        get :edit, id: admin_user.id
        expect_edit_success_with_model('user',corporate_customer_user.id)
      end
    end

    describe "POST 'create'" do
      it 'should redirect to root' do
        post :create, user: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params' do
        put :update, id: corporate_customer_user.id, user: valid_params
        expect_update_success_with_model('user', profile_url)
        expect(assigns(:user).id).to eq(corporate_customer_user.id)
      end

      it 'should respond OK to valid params and insist on their own user ID being updated' do
        put :update, id: admin_user.id, user: valid_params
        expect_update_success_with_model('user', profile_url)
        expect(assigns(:user).id).to eq(corporate_customer_user.id)
      end

      it 'should reject invalid params' do
        put :update, id: corporate_customer_user.id, user: {email: 'a'}
        expect_update_error_with_model('user')
        expect(assigns(:user).id).to eq(corporate_customer_user.id)
      end
    end

    describe "DELETE 'destroy'" do
      it 'should redirect to root' do
        delete :destroy, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "POST: 'change_password'" do
      it 'should respond OK to correct details' do
        post :change_password, user: {current_password: 'letSomeone1n', password: '456456456', password_confirmation: '456456456'}
        expect_change_password_success_with_model(profile_url)
      end

      it 'should respond ERROR to incorrect details' do
        post :change_password, user: {current_password: 'oops', password: '456456456', password_confirmation: '456456456'}
        expect_change_password_error_with_model(profile_url)
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
      it 'should see my own profile' do
        get :show, id: blogger_user.id
        expect_show_success_with_model('user', blogger_user.id)
      end

      it 'should see my own profile even if I ask for another' do
        get :show, id: admin_user.id
        expect_show_success_with_model('user', blogger_user.id)
      end
    end

    describe "GET 'new'" do
      it 'should redirect to root' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond with OK' do
        get :edit, id: blogger_user.id
        expect(response.status).to eq(200)
        expect_edit_success_with_model('user', blogger_user.id)
      end

      it 'should only allow editing of own user' do
        get :edit, id: admin_user.id
        expect_edit_success_with_model('user', blogger_user.id)
      end
    end

    describe "POST 'create'" do
      it 'should redirect to root' do
        post :create, user: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params' do
        put :update, id: blogger_user.id, user: valid_params
        expect_update_success_with_model('user', profile_url)
        expect(assigns(:user).id).to eq(blogger_user.id)
      end

      it 'should respond OK to valid params and insist on their own user ID being updated' do
        put :update, id: admin_user.id, user: valid_params
        expect_update_success_with_model('user', profile_url)
        expect(assigns(:user).id).to eq(blogger_user.id)
      end

      it 'should reject invalid params' do
        put :update, id: blogger_user.id, user: {email: 'a'}
        expect_update_error_with_model('user')
        expect(assigns(:user).id).to eq(blogger_user.id)
      end
    end

    describe "DELETE 'destroy'" do
      it 'should redirect to root' do
        delete :destroy, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "POST: 'change_password'" do
      it 'should respond OK to correct details' do
        post :change_password, user: {current_password: 'letSomeone1n', password: '456456456', password_confirmation: '456456456'}
        expect_change_password_success_with_model(profile_url)
      end

      it 'should respond ERROR to incorrect details' do
        post :change_password, user: {current_password: 'oops', password: '456456456', password_confirmation: '456456456'}
        expect_change_password_error_with_model(profile_url)
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
      it 'should see my own profile' do
        get :show, id: forum_manager_user.id
        expect_show_success_with_model('user', forum_manager_user.id)
      end

      it 'should see my own profile even if I ask for another' do
        get :show, id: admin_user.id
        expect_show_success_with_model('user', forum_manager_user.id)
      end
    end

    describe "GET 'new'" do
      it 'should redirect to root' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond with OK' do
        get :edit, id: forum_manager_user.id
        expect_edit_success_with_model('user', forum_manager_user.id)
      end

      it 'should only allow editing of own user' do
        get :edit, id: admin_user.id
        expect_edit_success_with_model('user', forum_manager_user.id)
      end
    end

    describe "POST 'create'" do
      it 'should redirect to root' do
        post :create, user: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params' do
        put :update, id: forum_manager_user.id, user: valid_params
        expect_update_success_with_model('user', profile_url)
        expect(assigns(:user).id).to eq(forum_manager_user.id)
      end

      it 'should respond OK to valid params and insist on their own user ID being updated' do
        put :update, id: admin_user.id, user: valid_params
        expect_update_success_with_model('user', profile_url)
        expect(assigns(:user).id).to eq(forum_manager_user.id)
      end

      it 'should reject invalid params' do
        put :update, id: forum_manager_user.id, user: {email: 'a'}
        expect_update_error_with_model('user')
        expect(assigns(:user).id).to eq(forum_manager_user.id)
      end
    end

    describe "DELETE 'destroy'" do
      it 'should redirect to root' do
        delete :destroy, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "POST: 'change_password'" do
      it 'should respond OK to correct details' do
        post :change_password, user: {current_password: 'letSomeone1n', password: '456456456', password_confirmation: '456456456'}
        expect_change_password_success_with_model(profile_url)
      end

      it 'should respond ERROR to incorrect details' do
        post :change_password, user: {current_password: 'oops', password: '456456456', password_confirmation: '456456456'}
        expect_change_password_error_with_model(profile_url)
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
      it 'should see my own profile' do
        get :show, id: content_manager_user.id
        expect_show_success_with_model('user', content_manager_user.id)
      end

      it 'should see my own profile even if I ask for another' do
        get :show, id: admin_user.id
        expect_show_success_with_model('user', content_manager_user.id)
      end
    end

    describe "GET 'new'" do
      it 'should redirect to root' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond with OK' do
        get :edit, id: content_manager_user.id
        expect_edit_success_with_model('user', content_manager_user.id)
      end

      it 'should only allow editing of own user' do
        get :edit, id: admin_user.id
        expect_edit_success_with_model('user', content_manager_user.id)
      end
    end

    describe "POST 'create'" do
      it 'should redirect to root' do
        post :create, user: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params' do
        put :update, id: content_manager_user.id, user: valid_params
        expect_update_success_with_model('user', profile_url)
        expect(assigns(:user).id).to eq(content_manager_user.id)
      end

      it 'should respond OK to valid params and insist on their own user ID being updated' do
        put :update, id: admin_user.id, user: valid_params
        expect_update_success_with_model('user', profile_url)
        expect(assigns(:user).id).to eq(content_manager_user.id)
      end

      it 'should reject invalid params' do
        put :update, id: content_manager_user.id, user: {email: 'a'}
        expect(response.status).to eq(200)
        expect_update_error_with_model('user')
        expect(assigns(:user).id).to eq(content_manager_user.id)
      end
    end

    describe "DELETE 'destroy'" do
      it 'should redirect to root' do
        delete :destroy, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "POST: 'change_password'" do
      it 'should respond OK to correct details' do
        post :change_password, user: {current_password: 'letSomeone1n', password: '456456456', password_confirmation: '456456456'}
        expect_change_password_success_with_model(profile_url)
      end

      it 'should respond ERROR to incorrect details' do
        post :change_password, user: {current_password: 'oops', password: '456456456', password_confirmation: '456456456'}
        expect_change_password_error_with_model(profile_url)
      end
    end

  end

  context 'Logged in as a admin_user' do

    before(:each) do
      activate_authlogic
      UserSession.create!(admin_user)
    end

    describe "GET 'index'" do
      it 'should redirect to root' do
        get :index
        expect_index_success_with_model('users', 9)
      end
    end

    describe "GET 'show/1'" do
      it 'should see my own profile' do
        get :show, id: individual_student_user.id
        expect_show_success_with_model('user', individual_student_user.id)
      end

      it 'should see my own profile even if I ask for another' do
        get :show, id: admin_user.id
        expect_show_success_with_model('user', admin_user.id)
      end
    end

    describe "GET 'new'" do
      it 'should redirect to root' do
        get :new
        expect_new_success_with_model('user')
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond with OK' do
        get :edit, id: individual_student_user.id
        expect_edit_success_with_model('user', individual_student_user.id)
      end

      it 'should only allow editing of own user' do
        get :edit, id: admin_user.id
        expect_edit_success_with_model('user', admin_user.id)
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, user: valid_params
        expect_create_success_with_model('user', users_url)
      end

      it 'should report error for invalid params' do
        post :create, user: {email: 'abc'}
        expect_create_error_with_model('user')
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params' do
        put :update, id: admin_user.id, user: valid_params
        expect_update_success_with_model('user', users_url)
      end

      it 'should respond OK to valid params and insist on their own user ID being updated' do
        put :update, id: individual_student_user.id, user: valid_params
        expect_update_success_with_model('user', users_url)
        expect(assigns(:user).id).to eq(individual_student_user.id)
      end

      it 'should reject invalid params' do
        put :update, id: individual_student_user.id, user: {email: 'a'}
        expect_update_error_with_model('user')
        expect(assigns(:user).id).to eq(individual_student_user.id)
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be OK if deleting normal user' do
        delete :destroy, id: individual_student_user.id
        expect_delete_success_with_model('user', users_url)
      end

      it 'should be ERROR if deleting admin user' do
        delete :destroy, id: admin_user.id
        expect_delete_error_with_model('user', users_url)
      end
    end

    describe "POST: 'change_password'" do
      it 'should respond OK to correct details' do
        post :change_password, user: {current_password: 'letSomeone1n', password: '456456456', password_confirmation: '456456456'}
        expect_change_password_success_with_model(users_url)
      end

      it 'should respond ERROR to incorrect details' do
        post :change_password, user: {current_password: 'oops', password: '456456456', password_confirmation: '456456456'}
        expect_change_password_error_with_model(users_url)
      end
    end

  end
end
