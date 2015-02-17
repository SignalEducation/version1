require 'rails_helper'
require 'support/users_and_groups_setup'
require 'stripe_mock'

describe SubscriptionPlansController, type: :controller do

  include_context 'users_and_groups_setup'

  let(:stripe_helper) { StripeMock.create_test_helper }
  let!(:start_stripe_mock) { StripeMock.start }
  let!(:subscription_plan_1) { FactoryGirl.create(:student_subscription_plan) }
  let!(:subscription_1) { FactoryGirl.create(:subscription,
                          subscription_plan_id: subscription_plan_1.id,
                          stripe_token: stripe_helper.generate_card_token) }
  let!(:subscription_plan_2) { FactoryGirl.create(:corporate_subscription_plan) }
  let!(:valid_params) { FactoryGirl.attributes_for(:subscription_plan) }

  #before { StripeMock.start }
  after { StripeMock.stop }

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
      it 'should respond ERROR not permitted' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      it 'should respond ERROR not permitted' do
        get :show, id: 1
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
        get :edit, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should respond ERROR not permitted' do
        post :create, currency: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond ERROR not permitted' do
        put :update, id: 1, currency: valid_params
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

    describe "GET 'index'" do
      it 'should respond ERROR not permitted' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      it 'should respond ERROR not permitted' do
        get :show, id: 1
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
        get :edit, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should respond ERROR not permitted' do
        post :create, currency: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond ERROR not permitted' do
        put :update, id: 1, currency: valid_params
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

    describe "GET 'show/1'" do
      it 'should respond ERROR not permitted' do
        get :show, id: 1
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
        get :edit, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should respond ERROR not permitted' do
        post :create, currency: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond ERROR not permitted' do
        put :update, id: 1, currency: valid_params
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

    describe "GET 'index'" do
      it 'should respond ERROR not permitted' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      it 'should respond ERROR not permitted' do
        get :show, id: 1
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
        get :edit, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should respond ERROR not permitted' do
        post :create, currency: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond ERROR not permitted' do
        put :update, id: 1, currency: valid_params
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

    describe "GET 'index'" do
      it 'should respond ERROR not permitted' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      it 'should respond ERROR not permitted' do
        get :show, id: 1
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
        get :edit, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should respond ERROR not permitted' do
        post :create, currency: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond ERROR not permitted' do
        put :update, id: 1, currency: valid_params
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

    describe "GET 'index'" do
      it 'should respond ERROR not permitted' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      it 'should respond ERROR not permitted' do
        get :show, id: 1
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
        get :edit, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should respond ERROR not permitted' do
        post :create, currency: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond ERROR not permitted' do
        put :update, id: 1, currency: valid_params
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

    describe "GET 'index'" do
      it 'should respond ERROR not permitted' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      it 'should respond ERROR not permitted' do
        get :show, id: 1
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
        get :edit, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      it 'should respond ERROR not permitted' do
        post :create, currency: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond ERROR not permitted' do
        put :update, id: 1, currency: valid_params
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

    describe "GET 'index'" do
      it 'should respond OK' do
        get :index
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:index)
        expect(assigns(:student_subscription_plans).first.class).to eq(SubscriptionPlan)
        expect(assigns(:student_subscription_plans).first.class).to eq(SubscriptionPlan)
        expect(assigns(:corporate_subscription_plans).count).to eq(1)
      end
    end

    describe "GET 'show/1'" do
      it 'should see subscription_plan_1' do
        get :show, id: subscription_plan_1.id
        expect_show_success_with_model('subscription_plan', subscription_plan_1.id)
      end

      # optional - some other object
      it 'should see subscription_plan_2' do
        get :show, id: subscription_plan_2.id
        expect_show_success_with_model('subscription_plan', subscription_plan_2.id)
      end
    end

    describe "GET 'new'" do
      it 'should respond OK' do
        get :new
        expect_new_success_with_model('subscription_plan')
      end
    end

    describe "GET 'edit/1'" do
      it 'should respond OK with subscription_plan_1' do
        get :edit, id: subscription_plan_1.id
        expect_edit_success_with_model('subscription_plan', subscription_plan_1.id)
      end

      # optional
      it 'should respond OK with subscription_plan_2' do
        get :edit, id: subscription_plan_2.id
        expect_edit_success_with_model('subscription_plan', subscription_plan_2.id)
      end
    end

    describe "POST 'create'" do
      it 'should report OK for valid params' do
        post :create, subscription_plan: valid_params
        expect_create_success_with_model('subscription_plan', subscription_plans_url)
      end

      it 'should report error for invalid params' do
        post :create, subscription_plan: {valid_params.keys.first => ''}
        expect_create_error_with_model('subscription_plan')
      end
    end

    describe "PUT 'update/1'" do
      it 'should respond OK to valid params for subscription_plan_1' do
        put :update, id: subscription_plan_1.id, subscription_plan: {name: 'new-name'}
        expect_update_success_with_model('subscription_plan', subscription_plans_url)
        expect(assigns(:subscription_plan).name).to eq('new-name')
      end

      it 'should reject invalid params' do
        put :update, id: subscription_plan_1.id, subscription_plan: {name: nil}
        expect_update_error_with_model('subscription_plan')
        expect(assigns(:subscription_plan).id).to eq(subscription_plan_1.id)
      end
    end

    describe "DELETE 'destroy'" do
      it 'should be ERROR as children exist' do
        delete :destroy, id: subscription_plan_1.id
        # expect_delete_success_with_model('subscription_plan', subscription_plans_url)
        expect_delete_error_with_model('subscription_plan', subscription_plans_url)
      end

      it 'should be OK as no dependencies exist' do
        delete :destroy, id: subscription_plan_2.id
        expect_delete_success_with_model('subscription_plan', subscription_plans_url)
      end
    end

  end

end
