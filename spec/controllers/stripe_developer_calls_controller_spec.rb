require 'rails_helper'
require 'support/users_and_groups_setup'

describe StripeDeveloperCallsController, type: :controller do

  include_context 'users_and_groups_setup'

  let!(:stripe_developer_call_1) { FactoryGirl.create(:stripe_developer_call,
                                                      prevent_delete: false) }
  let!(:stripe_developer_call_2) { FactoryGirl.create(:stripe_developer_call,
                                                      prevent_delete: true) }
  let!(:valid_params) { FactoryGirl.attributes_for(:stripe_developer_call,
                        params_received: {name: 'Dan', number: 123}) }

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
      it 'should see stripe_developer_call_1' do
        get :show, id: stripe_developer_call_1.id
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
      it 'should respond OK with stripe_developer_call_1' do
        get :edit, id: stripe_developer_call_1.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, stripe_developer_call: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for stripe_developer_call_1' do
        put :update, id: stripe_developer_call_1.id, stripe_developer_call: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, id: stripe_developer_call_1.id
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
      it 'should see stripe_developer_call_1' do
        get :show, id: stripe_developer_call_1.id
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
      it 'should respond OK with stripe_developer_call_1' do
        get :edit, id: stripe_developer_call_1.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, stripe_developer_call: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for stripe_developer_call_1' do
        put :update, id: stripe_developer_call_1.id, stripe_developer_call: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, id: stripe_developer_call_1.id
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

    describe "GET 'show/1'" do
      it 'should see stripe_developer_call_1' do
        get :show, id: stripe_developer_call_1.id
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
      it 'should respond OK with stripe_developer_call_1' do
        get :edit, id: stripe_developer_call_1.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, stripe_developer_call: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for stripe_developer_call_1' do
        put :update, id: stripe_developer_call_1.id, stripe_developer_call: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, id: stripe_developer_call_1.id
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

    describe "GET 'show/1'" do
      it 'should see stripe_developer_call_1' do
        get :show, id: stripe_developer_call_1.id
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
      it 'should respond OK with stripe_developer_call_1' do
        get :edit, id: stripe_developer_call_1.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, stripe_developer_call: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for stripe_developer_call_1' do
        put :update, id: stripe_developer_call_1.id, stripe_developer_call: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, id: stripe_developer_call_1.id
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
      it 'should see stripe_developer_call_1' do
        get :show, id: stripe_developer_call_1.id
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
      it 'should respond OK with stripe_developer_call_1' do
        get :edit, id: stripe_developer_call_1.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, stripe_developer_call: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for stripe_developer_call_1' do
        put :update, id: stripe_developer_call_1.id, stripe_developer_call: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, id: stripe_developer_call_1.id
        expect_bounce_as_not_allowed
      end
    end
  end

  context 'Logged in as a forum_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(forum_manager_user)
    end

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      it 'should see stripe_developer_call_1' do
        get :show, id: stripe_developer_call_1.id
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
      it 'should respond OK with stripe_developer_call_1' do
        get :edit, id: stripe_developer_call_1.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, stripe_developer_call: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for stripe_developer_call_1' do
        put :update, id: stripe_developer_call_1.id, stripe_developer_call: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, id: stripe_developer_call_1.id
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
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      it 'should see stripe_developer_call_1' do
        get :show, id: stripe_developer_call_1.id
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
      it 'should respond OK with stripe_developer_call_1' do
        get :edit, id: stripe_developer_call_1.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, stripe_developer_call: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for stripe_developer_call_1' do
        put :update, id: stripe_developer_call_1.id, stripe_developer_call: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, id: stripe_developer_call_1.id
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
        expect_index_success_with_model('stripe_developer_calls', 2)
      end
    end

    describe "GET 'show/1'" do
      it 'should see stripe_developer_call_1' do
        get :show, id: stripe_developer_call_1.id
        expect_show_success_with_model('stripe_developer_call', stripe_developer_call_1.id)
      end

      # optional - some other object
      it 'should see stripe_developer_call_2' do
        get :show, id: stripe_developer_call_2.id
        expect_show_success_with_model('stripe_developer_call', stripe_developer_call_2.id)
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_new_success_with_model('stripe_developer_call')
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with stripe_developer_call_1' do
        get :edit, id: stripe_developer_call_1.id
        expect_edit_success_with_model('stripe_developer_call', stripe_developer_call_1.id)
      end

      # optional
      it 'should respond OK with stripe_developer_call_2' do
        get :edit, id: stripe_developer_call_2.id
        expect_edit_success_with_model('stripe_developer_call', stripe_developer_call_2.id)
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, stripe_developer_call: valid_params
        expect_create_success_with_model('stripe_developer_call', stripe_developer_calls_url)
      end

      it 'should report error for invalid params' do
        post :create, stripe_developer_call: {user_id: nil}
        expect_create_error_with_model('stripe_developer_call')
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for stripe_developer_call_1' do
        put :update, id: stripe_developer_call_1.id, stripe_developer_call: valid_params
        expect_update_success_with_model('stripe_developer_call', stripe_developer_calls_url)
      end

      # optional
      it 'should respond OK to valid params for stripe_developer_call_2' do
        put :update, id: stripe_developer_call_2.id, stripe_developer_call: {user_id: nil}
        expect_update_error_with_model('stripe_developer_call')
        expect(assigns(:stripe_developer_call).id).to eq(stripe_developer_call_2.id)
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, id: stripe_developer_call_2.id
        expect_delete_error_with_model('stripe_developer_call', stripe_developer_calls_url)
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: stripe_developer_call_1.id
        expect_delete_success_with_model('stripe_developer_call', stripe_developer_calls_url)
      end
    end

  end

end
