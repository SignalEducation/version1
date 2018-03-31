require 'rails_helper'
require 'support/system_setup'
require 'support/users_and_groups_setup'

RSpec.describe SubscriptionManagementController, :type => :controller do

  include_context 'system_setup'
  include_context 'users_and_groups_setup'

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

  context 'Logged in as a valid_trial_student: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(valid_trial_student)
    end

    describe "GET 'index'" do
      it 'should bounce as not allowed' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      it 'should bounce as not allowed' do
        get :show, id: subscription_plan_category_1.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      it 'should bounce as not allowed' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should bounce as not allowed' do
        get :edit, id: subscription_plan_category_1.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should bounce as not allowed' do
        post :create, subscription_plan_category: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should bounce as not allowed' do
        put :update, id: subscription_plan_category_1.id, subscription_plan_category: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "DELETE 'destroy'" do
      it 'should bounce as not allowed' do
        delete :destroy, id: subscription_plan_category_1.id
        expect_bounce_as_not_allowed
      end
    end
  end

  context 'Logged in as a invalid_trial_student: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(invalid_trial_student)
    end

    describe "GET 'index'" do
      it 'should bounce as not allowed' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      it 'should bounce as not allowed' do
        get :show, id: subscription_plan_category_1.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      it 'should bounce as not allowed' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should bounce as not allowed' do
        get :edit, id: subscription_plan_category_1.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should bounce as not allowed' do
        post :create, subscription_plan_category: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should bounce as not allowed' do
        put :update, id: subscription_plan_category_1.id, subscription_plan_category: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "DELETE 'destroy'" do
      it 'should bounce as not allowed' do
        delete :destroy, id: subscription_plan_category_1.id
        expect_bounce_as_not_allowed
      end
    end
  end

  context 'Logged in as a valid_subscription_student: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(valid_subscription_student)
    end

    describe "GET 'index'" do
      it 'should bounce as not allowed' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      it 'should bounce as not allowed' do
        get :show, id: subscription_plan_category_1.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      it 'should bounce as not allowed' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should bounce as not allowed' do
        get :edit, id: subscription_plan_category_1.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should bounce as not allowed' do
        post :create, subscription_plan_category: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should bounce as not allowed' do
        put :update, id: subscription_plan_category_1.id, subscription_plan_category: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "DELETE 'destroy'" do
      it 'should bounce as not allowed' do
        delete :destroy, id: subscription_plan_category_1.id
        expect_bounce_as_not_allowed
      end
    end
  end

  context 'Logged in as a invalid_subscription_student: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(invalid_subscription_student)
    end

    describe "GET 'index'" do
      it 'should bounce as not allowed' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      it 'should bounce as not allowed' do
        get :show, id: subscription_plan_category_1.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      it 'should bounce as not allowed' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should bounce as not allowed' do
        get :edit, id: subscription_plan_category_1.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should bounce as not allowed' do
        post :create, subscription_plan_category: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should bounce as not allowed' do
        put :update, id: subscription_plan_category_1.id, subscription_plan_category: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "DELETE 'destroy'" do
      it 'should bounce as not allowed' do
        delete :destroy, id: subscription_plan_category_1.id
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
      it 'should bounce as not allowed' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      it 'should bounce as not allowed' do
        get :show, id: subscription_plan_category_1.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      it 'should bounce as not allowed' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should bounce as not allowed' do
        get :edit, id: subscription_plan_category_1.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should bounce as not allowed' do
        post :create, subscription_plan_category: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should bounce as not allowed' do
        put :update, id: subscription_plan_category_1.id, subscription_plan_category: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "DELETE 'destroy'" do
      it 'should bounce as not allowed' do
        delete :destroy, id: subscription_plan_category_1.id
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
      it 'should bounce as not allowed' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      it 'should bounce as not allowed' do
        get :show, id: subscription_plan_category_1.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      it 'should bounce as not allowed' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should bounce as not allowed' do
        get :edit, id: subscription_plan_category_1.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should bounce as not allowed' do
        post :create, subscription_plan_category: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should bounce as not allowed' do
        put :update, id: subscription_plan_category_1.id, subscription_plan_category: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "DELETE 'destroy'" do
      it 'should bounce as not allowed' do
        delete :destroy, id: subscription_plan_category_1.id
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
      it 'should bounce as not allowed' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      it 'should bounce as not allowed' do
        get :show, id: subscription_plan_category_1.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      it 'should bounce as not allowed' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should bounce as not allowed' do
        get :edit, id: subscription_plan_category_1.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should bounce as not allowed' do
        post :create, subscription_plan_category: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should bounce as not allowed' do
        put :update, id: subscription_plan_category_1.id, subscription_plan_category: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "DELETE 'destroy'" do
      it 'should bounce as not allowed' do
        delete :destroy, id: subscription_plan_category_1.id
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
      it 'should bounce as not allowed' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      it 'should bounce as not allowed' do
        get :show, id: subscription_plan_category_1.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      it 'should bounce as not allowed' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should bounce as not allowed' do
        get :edit, id: subscription_plan_category_1.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should bounce as not allowed' do
        post :create, subscription_plan_category: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should bounce as not allowed' do
        put :update, id: subscription_plan_category_1.id, subscription_plan_category: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "DELETE 'destroy'" do
      it 'should bounce as not allowed' do
        delete :destroy, id: subscription_plan_category_1.id
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
      it 'should bounce as not allowed' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      it 'should bounce as not allowed' do
        get :show, id: subscription_plan_category_1.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      it 'should bounce as not allowed' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edit/1'" do
      it 'should bounce as not allowed' do
        get :edit, id: subscription_plan_category_1.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should bounce as not allowed' do
        post :create, subscription_plan_category: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should bounce as not allowed' do
        put :update, id: subscription_plan_category_1.id, subscription_plan_category: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "DELETE 'destroy'" do
      it 'should bounce as not allowed' do
        delete :destroy, id: subscription_plan_category_1.id
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
        expect_index_success_with_model('subscription_plan_categories', 2)
      end
    end

    describe "GET 'show/1'" do
      it 'should see subscription_plan_category_1' do
        get :show, id: subscription_plan_category_1.id
        expect_show_success_with_model('subscription_plan_category', subscription_plan_category_1.id)
      end

      it 'should see subscription_plan_category_2' do
        get :show, id: subscription_plan_category_2.id
        expect_show_success_with_model('subscription_plan_category', subscription_plan_category_2.id)
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_new_success_with_model('subscription_plan_category')
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with subscription_plan_category_1' do
        get :edit, id: subscription_plan_category_1.id
        expect_edit_success_with_model('subscription_plan_category', subscription_plan_category_1.id)
      end

      it 'should respond OK with subscription_plan_category_2' do
        get :edit, id: subscription_plan_category_2.id
        expect_edit_success_with_model('subscription_plan_category', subscription_plan_category_2.id)
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, subscription_plan_category: valid_params
        expect_create_success_with_model('subscription_plan_category', subscription_plan_categories_url)
      end

      it 'should report error for invalid params' do
        post :create, subscription_plan_category: {valid_params.keys.first => ''}
        expect_create_error_with_model('subscription_plan_category')
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for subscription_plan_category_1' do
        put :update, id: subscription_plan_category_1.id, subscription_plan_category: valid_params
        expect_update_success_with_model('subscription_plan_category', subscription_plan_categories_url)
      end

      it 'should respond OK to valid params for subscription_plan_category_2' do
        put :update, id: subscription_plan_category_2.id, subscription_plan_category: valid_params
        expect_update_success_with_model('subscription_plan_category', subscription_plan_categories_url)
        expect(assigns(:subscription_plan_category).id).to eq(subscription_plan_category_2.id)
      end

      it 'should reject invalid params' do
        put :update, id: subscription_plan_category_1.id, subscription_plan_category: {valid_params.keys.first => ''}
        expect_update_error_with_model('subscription_plan_category')
        expect(assigns(:subscription_plan_category).id).to eq(subscription_plan_category_1.id)
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, id: subscription_plan_category_1.id
        expect_delete_error_with_model('subscription_plan_category', subscription_plan_categories_url)
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: subscription_plan_category_2.id
        expect_delete_success_with_model('subscription_plan_category', subscription_plan_categories_url)
      end
    end
  end

end