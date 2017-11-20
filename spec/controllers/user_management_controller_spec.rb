require 'rails_helper'
require 'support/users_and_groups_setup'
require 'support/course_content'
require 'support/system_setup'
require 'stripe_mock'

describe UserManagementController, type: :controller do

  include_context 'users_and_groups_setup'
  include_context 'course_content'
  include_context 'system_setup'



  let(:stripe_helper) { StripeMock.create_test_helper }
  let!(:start_stripe_mock) { StripeMock.start }
  let!(:subscription_plan_1) { FactoryGirl.create(:student_subscription_plan) }
  let!(:subscription_plan_2) { FactoryGirl.create(:student_subscription_plan) }
  let!(:upgrading_user) { FactoryGirl.create(:student_user) }
  let!(:student_user_1) { FactoryGirl.create(:student_user) }
  let!(:subscription_payment_card) { FactoryGirl.create(:subscription_payment_card, user_id: student_user_1.id) }
  let!(:subscription_1) { x = FactoryGirl.create(:subscription,
                                                 user_id: student_user_1.id,
                                                 subscription_plan_id: subscription_plan_1.id,
                                                 active: true,
                                                 current_status: 'canceled',
                                                 stripe_token: stripe_helper.generate_card_token)
  student_user_1.stripe_customer_id = x.stripe_customer_id
  student_user_1.save
  x }
  let!(:valid_params) { FactoryGirl.attributes_for(:student_user, user_group_id: student_user_group.id) }


  context 'Not logged in...' do

    describe "GET account" do
      xit 'should see my own profile' do
        get :account, id: student_user.id
        expect_bounce_as_not_signed_in
      end
    end

    describe "GET 'index'" do
      xit 'should redirect to root' do
        get :index
        expect_bounce_as_not_signed_in
      end
    end

    describe "GET 'show/1'" do
      xit 'should redirect to root' do
        get :show, id: student_user.id
        expect_bounce_as_not_signed_in
      end
    end

    describe "GET 'user_personal_details'" do
      xit 'should redirect to root' do
        get :user_personal_details, user_id: student_user.id
        expect_bounce_as_not_signed_in
      end
    end

    describe "GET 'user_subscription_status'" do
      xit 'should redirect to root' do
        get :user_subscription_status, user_id: student_user.id
        expect_bounce_as_not_signed_in
      end
    end

    describe "GET 'user_enrollments_details'" do
      xit 'should redirect to root' do
        get :user_enrollments_details, user_id: student_user.id
        expect_bounce_as_not_signed_in
      end
    end

    describe "GET 'user_purchases_details'" do
      xit 'should redirect to root' do
        get :user_purchases_details, user_id: student_user.id
        expect_bounce_as_not_signed_in
      end
    end

    describe "GET 'user_courses_status'" do
      xit 'should redirect to root' do
        get :user_courses_status, user_id: student_user.id
        expect_bounce_as_not_signed_in
      end
    end

    describe "GET 'new'" do
      xit 'should redirect to root' do
        get :new
        expect_bounce_as_not_signed_in
      end
    end

    describe "GET 'edxit/1'" do
      xit 'should redirect to root' do
        get :edxit, id: student_user.id
        expect_bounce_as_not_signed_in
      end
    end

    describe "POST 'create'" do
      xit 'should redirect to root' do
        post :create, user: valid_params
        expect_bounce_as_not_signed_in
      end
    end

    describe "PUT 'update/1'" do
      xit 'should respond OK to valid params' do
        put :update, id: student_user.id, user: valid_params
        expect_bounce_as_not_signed_in
      end

      xit 'should respond OK to valid params and insist on their own user ID being updated' do
        put :update, id: admin_user.id, user: valid_params
        expect_bounce_as_not_signed_in
      end

      xit 'should reject invalid params' do
        put :update, id: student_user.id, user: {email: 'a'}
        expect_bounce_as_not_signed_in
      end
    end

    describe "DELETE 'destroy'" do
      xit 'should redirect to root' do
        delete :destroy, id: 1
        expect_bounce_as_not_signed_in
      end
    end

    describe "GET 'reactivate_account'" do
      xit 'should redirect to root' do
        get :reactivate_account, user_id: student_user.id
        expect_bounce_as_not_signed_in
      end
    end

    describe "POST 'reactivate_account_subscription'" do
      xit 'should redirect to root' do
        post :reactivate_account_subscription, user_id: student_user.id
        expect_bounce_as_not_signed_in
      end
    end

    describe "GET 'reactivation_complete'" do
      xit 'should redirect to root' do
        post :reactivation_complete, id: 1
        expect_bounce_as_not_signed_in
      end
    end

    describe "GET 'subscription_invoice'" do
      xit 'should redirect to root' do
        post :subscription_invoice, id: 1
        expect_bounce_as_not_signed_in
      end
    end

    describe "POST: 'change_password'" do
      xit 'should respond OK to correct details' do
        post :change_password, user: {current_password: 'letSomeone1n', password: '456456456', password_confirmation: '456456456'}
        expect_bounce_as_not_signed_in
      end

      xit 'should respond ERROR to incorrect details' do
        post :change_password, user: {current_password: 'oops', password: '456456456', password_confirmation: '456456456'}
        expect_bounce_as_not_signed_in
      end
    end

  end

  context 'Logged in as a student_user' do

    before(:each) do
      activate_authlogic
      UserSession.create!(student_user)
    end

    describe "GET 'account'" do
      xit 'should see my own profile' do
        get :account, id: student_user.id
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:account)
      end
    end

    describe "GET 'index'" do
      xit 'should redirect to root' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      xit 'should redirect to root' do
        get :show, id: student_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'user_personal_details'" do
      xit 'should redirect to root' do
        get :user_personal_details, user_id: student_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'user_subscription_status'" do
      xit 'should redirect to root' do
        get :user_subscription_status, user_id: student_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'user_enrollments_details'" do
      xit 'should redirect to root' do
        get :user_enrollments_details, user_id: student_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'user_purchases_details'" do
      xit 'should redirect to root' do
        get :user_purchases_details, user_id: student_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'user_courses_status'" do
      xit 'should redirect to root' do
        get :user_courses_status, user_id: student_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      xit 'should redirect to root' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edxit/1'" do
      xit 'should redirect to root' do
        get :edxit, id: student_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      xit 'should redirect to root' do
        post :create, user: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      xit 'should respond OK to valid params' do
        put :update, id: student_user.id, user: valid_params
        expect_update_success_wxith_model('user', account_url)
        expect(assigns(:user).id).to eq(student_user.id)
      end

      xit 'should respond OK to valid params and insist on their own user ID being updated' do
        put :update, id: admin_user.id, user: valid_params
        expect_update_success_wxith_model('user', account_url)
        expect(assigns(:user).id).to eq(student_user.id)
      end

      xit 'should reject invalid params' do
        put :update, id: student_user.id, user: {email: 'a'}
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(account_url(anchor: 'personal-details-modal'))
      end
    end

    describe "DELETE 'destroy'" do
      xit 'should redirect to root' do
        delete :destroy, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'reactivate_account'" do
      xit 'should redirect to root as no subscription exists for user' do
        get :reactivate_account, user_id: student_user.id
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to account_url(anchor: :subscriptions)
      end

      xit 'successfully render reactivate_account view' do
        get :reactivate_account, user_id: student_user_1.id
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:reactivate_account)
      end
    end

    describe "POST 'reactivate_account_subscription'" do
      xit 'create new subscription for the user' do
        stripe_customer = Stripe::Customer.create(email: student_user_1.email)
        student_user_1.update_attribute(:stripe_customer_id, stripe_customer.id)
        stripe_subscription = stripe_customer.subscriptions.create(plan: subscription_plan_1.stripe_guid, trial_end: 'now', source: stripe_helper.generate_card_token)
        subscription_1.update_attribute(:stripe_guid, stripe_subscription.id)
        subscription_1.update_attribute(:stripe_customer_id, stripe_customer.id)

        post :reactivate_account_subscription, user_id: student_user_1.id, subscription: {subscription_plan_id: subscription_plan_2.id, stripe_token: stripe_helper.generate_card_token, terms_and_condxitions: 'true'}, coupon: ''
        expect(student_user_1.active_subscription.current_status).to eq('active')
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(reactivation_complete_url)
      end
    end

    describe "GET 'reactivation_complete'" do
      xit 'should redirect to root' do
        post :reactivation_complete, user_id: student_user_1.id
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:reactivation_complete)
      end
    end

    describe "GET 'subscription_invoice'" do
      xit 'should redirect to root' do
        post :subscription_invoice, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "POST: 'change_password'" do
      xit 'should respond OK to correct details' do
        post :change_password, user: {current_password: 'letSomeone1n', password: '456456456', password_confirmation: '456456456'}
        expect_change_password_success_wxith_model(account_url)
      end

      xit 'should respond ERROR to incorrect details' do
        post :change_password, user: {current_password: 'oops', password: '456456456', password_confirmation: '456456456'}
        expect_change_password_error_wxith_model(account_url)
      end
    end

  end

  context 'Logged in as a comp_user' do

    before(:each) do
      activate_authlogic
      UserSession.create!(comp_user)
    end

    describe "GET account" do
      xit 'should see my own profile' do
        get :account, id: comp_user.id
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:account)
      end
    end

    describe "GET 'index'" do
      xit 'should redirect to root' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      xit 'should redirect to root' do
        get :show, id: comp_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'user_personal_details'" do
      xit 'should redirect to root' do
        get :user_personal_details, user_id: comp_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'user_subscription_status'" do
      xit 'should redirect to root' do
        get :user_subscription_status, user_id: comp_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'user_enrollments_details'" do
      xit 'should redirect to root' do
        get :user_enrollments_details, user_id: comp_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'user_purchases_details'" do
      xit 'should redirect to root' do
        get :user_purchases_details, user_id: comp_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'user_courses_status'" do
      xit 'should redirect to root' do
        get :user_courses_status, user_id: comp_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      xit 'should redirect to root' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edxit/1'" do
      xit 'should redirect to root' do
        get :edxit, id: comp_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      xit 'should redirect to root' do
        post :create, user: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      xit 'should respond OK to valid params' do
        put :update, id: comp_user.id, user: valid_params
        expect_update_success_wxith_model('user', account_url)
        expect(assigns(:user).id).to eq(comp_user.id)
      end

      xit 'should respond OK to valid params and insist on their own user ID being updated' do
        put :update, id: admin_user.id, user: valid_params
        expect_update_success_wxith_model('user', account_url)
        expect(assigns(:user).id).to eq(comp_user.id)
      end

      xit 'should reject invalid params' do
        put :update, id: comp_user.id, user: {email: 'a'}
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(account_url(anchor: 'personal-details-modal'))
      end
    end

    describe "DELETE 'destroy'" do
      xit 'should redirect to root' do
        delete :destroy, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'reactivate_account'" do
      xit 'should redirect to root' do
        get :reactivate_account, user_id: comp_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'reactivate_account_subscription'" do
      xit 'should redirect to root' do
        post :reactivate_account_subscription, user_id: comp_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'reactivation_complete'" do
      xit 'should redirect to root' do
        post :reactivation_complete, user_id: comp_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'subscription_invoice'" do
      xit 'should redirect to root' do
        post :subscription_invoice, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "POST: 'change_password'" do
      xit 'should respond OK to correct details' do
        post :change_password, user: {current_password: 'letSomeone1n', password: '456456456', password_confirmation: '456456456'}
        expect_change_password_success_wxith_model(account_url)
      end

      xit 'should respond ERROR to incorrect details' do
        post :change_password, user: {current_password: 'oops', password: '456456456', password_confirmation: '456456456'}
        expect_change_password_error_wxith_model(account_url)
      end
    end

  end

  context 'Logged in as a tutor_user' do

    before(:each) do
      activate_authlogic
      UserSession.create!(tutor_user)
    end

    describe "GET account" do
      xit 'should see my own profile' do
        get :account, id: tutor_user.id
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:account)
      end
    end

    describe "GET 'index'" do
      xit 'should redirect to root' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      xit 'should redirect to root' do
        get :show, id: tutor_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'user_personal_details'" do
      xit 'should redirect to root' do
        get :user_personal_details, user_id: tutor_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'user_subscription_status'" do
      xit 'should redirect to root' do
        get :user_subscription_status, user_id: tutor_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'user_enrollments_details'" do
      xit 'should redirect to root' do
        get :user_enrollments_details, user_id: tutor_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'user_purchases_details'" do
      xit 'should redirect to root' do
        get :user_purchases_details, user_id: tutor_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'user_courses_status'" do
      xit 'should redirect to root' do
        get :user_courses_status, user_id: tutor_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      xit 'should redirect to root' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edxit/1'" do
      xit 'should redirect to root' do
        get :edxit, id: tutor_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      xit 'should redirect to root' do
        post :create, user: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      xit 'should respond OK to valid params' do
        put :update, id: tutor_user.id, user: valid_params
        expect_update_success_wxith_model('user', account_url)
        expect(assigns(:user).id).to eq(tutor_user.id)
      end

      xit 'should respond OK to valid params and insist on their own user ID being updated' do
        put :update, id: admin_user.id, user: valid_params
        expect_update_success_wxith_model('user', account_url)
        expect(assigns(:user).id).to eq(tutor_user.id)
      end

      xit 'should reject invalid params' do
        put :update, id: tutor_user.id, user: {email: 'a'}
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(account_url(anchor: 'personal-details-modal'))
      end
    end

    describe "DELETE 'destroy'" do
      xit 'should redirect to root' do
        delete :destroy, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'reactivate_account'" do
      xit 'should redirect to root' do
        get :reactivate_account, user_id: tutor_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'reactivate_account_subscription'" do
      xit 'should redirect to root' do
        post :reactivate_account_subscription, user_id: tutor_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'reactivation_complete'" do
      xit 'should redirect to root' do
        post :reactivation_complete, user_id: tutor_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'subscription_invoice'" do
      xit 'should redirect to root' do
        post :subscription_invoice, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "POST: 'change_password'" do
      xit 'should respond OK to correct details' do
        post :change_password, user: {current_password: 'letSomeone1n', password: '456456456', password_confirmation: '456456456'}
        expect_change_password_success_wxith_model(account_url)
      end

      xit 'should respond ERROR to incorrect details' do
        post :change_password, user: {current_password: 'oops', password: '456456456', password_confirmation: '456456456'}
        expect_change_password_error_wxith_model(account_url)
      end
    end

  end


  context 'Logged in as a content_manager_user' do

    before(:each) do
      activate_authlogic
      UserSession.create!(content_manager_user)
    end

    describe "GET account" do
      xit 'should see my own profile' do
        get :account, id: content_manager_user.id
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:account)
      end
    end

    describe "GET 'index'" do
      xit 'should redirect to root' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      xit 'should redirect to root' do
        get :show, id: content_manager_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'user_personal_details'" do
      xit 'should redirect to root' do
        get :user_personal_details, user_id: content_manager_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'user_subscription_status'" do
      xit 'should redirect to root' do
        get :user_subscription_status, user_id: content_manager_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'user_enrollments_details'" do
      xit 'should redirect to root' do
        get :user_enrollments_details, user_id: content_manager_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'user_purchases_details'" do
      xit 'should redirect to root' do
        get :user_purchases_details, user_id: content_manager_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'user_courses_status'" do
      xit 'should redirect to root' do
        get :user_courses_status, user_id: content_manager_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      xit 'should redirect to root' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edxit/1'" do
      xit 'should redirect to root' do
        get :edxit, id: content_manager_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      xit 'should redirect to root' do
        post :create, user: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      xit 'should respond OK to valid params' do
        put :update, id: content_manager_user.id, user: valid_params
        expect_update_success_wxith_model('user', account_url)
        expect(assigns(:user).id).to eq(content_manager_user.id)

      end

      xit 'should respond OK to valid params and insist on their own user ID being updated' do
        put :update, id: admin_user.id, user: valid_params
        expect_update_success_wxith_model('user', account_url)
        expect(assigns(:user).id).to eq(content_manager_user.id)

      end

      xit 'should reject invalid params' do
        put :update, id: content_manager_user.id, user: {email: 'a'}
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(account_url(anchor: 'personal-details-modal'))

      end
    end

    describe "DELETE 'destroy'" do
      xit 'should redirect to root' do
        delete :destroy, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'reactivate_account'" do
      xit 'should redirect to root' do
        get :reactivate_account, user_id: content_manager_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'reactivate_account_subscription'" do
      xit 'should redirect to root' do
        post :reactivate_account_subscription, user_id: content_manager_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'reactivation_complete'" do
      xit 'should redirect to root' do
        post :reactivation_complete, user_id: content_manager_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'subscription_invoice'" do
      xit 'should redirect to root' do
        post :subscription_invoice, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "POST: 'change_password'" do
      xit 'should respond OK to correct details' do
        post :change_password, user: {current_password: 'letSomeone1n', password: '456456456', password_confirmation: '456456456'}
        expect_change_password_success_wxith_model(account_url)
      end

      xit 'should respond ERROR to incorrect details' do
        post :change_password, user: {current_password: 'oops', password: '456456456', password_confirmation: '456456456'}
        expect_change_password_error_wxith_model(account_url)
      end
    end

  end

  context 'Logged in as a marketing_manager_user' do

    before(:each) do
      activate_authlogic
      UserSession.create!(marketing_manager_user)
    end

    describe "GET account" do
      xit 'should see my own profile' do
        get :account, id: marketing_manager_user.id
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:account)
      end
    end

    describe "GET 'index'" do
      xit 'should redirect to root' do
        get :index
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'show/1'" do
      xit 'should redirect to root' do
        get :show, id: marketing_manager_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'user_personal_details'" do
      xit 'should redirect to root' do
        get :user_personal_details, user_id: marketing_manager_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'user_subscription_status'" do
      xit 'should redirect to root' do
        get :user_subscription_status, user_id: marketing_manager_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'user_enrollments_details'" do
      xit 'should redirect to root' do
        get :user_enrollments_details, user_id: marketing_manager_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'user_purchases_details'" do
      xit 'should redirect to root' do
        get :user_purchases_details, user_id: marketing_manager_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'user_courses_status'" do
      xit 'should redirect to root' do
        get :user_courses_status, user_id: marketing_manager_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'new'" do
      xit 'should redirect to root' do
        get :new
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'edxit/1'" do
      xit 'should redirect to root' do
        get :edxit, id: marketing_manager_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'create'" do
      xit 'should redirect to root' do
        post :create, user: valid_params
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update/1'" do
      xit 'should respond OK to valid params' do
        put :update, id: marketing_manager_user.id, user: valid_params
        expect_update_success_wxith_model('user', account_url)
        expect(assigns(:user).id).to eq(marketing_manager_user.id)

      end

      xit 'should respond OK to valid params and insist on their own user ID being updated' do
        put :update, id: admin_user.id, user: valid_params
        expect_update_success_wxith_model('user', account_url)
        expect(assigns(:user).id).to eq(marketing_manager_user.id)

      end

      xit 'should reject invalid params' do
        put :update, id: marketing_manager_user.id, user: {email: 'a'}
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(account_url(anchor: 'personal-details-modal'))

      end
    end

    describe "DELETE 'destroy'" do
      xit 'should redirect to root' do
        delete :destroy, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'reactivate_account'" do
      xit 'should redirect to root' do
        get :reactivate_account, user_id: marketing_manager_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "POST 'reactivate_account_subscription'" do
      xit 'should redirect to root' do
        post :reactivate_account_subscription, user_id: marketing_manager_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'reactivation_complete'" do
      xit 'should redirect to root' do
        post :reactivation_complete, user_id: marketing_manager_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'subscription_invoice'" do
      xit 'should redirect to root' do
        post :subscription_invoice, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "POST: 'change_password'" do
      xit 'should respond OK to correct details' do
        post :change_password, user: {current_password: 'letSomeone1n', password: '456456456', password_confirmation: '456456456'}
        expect_change_password_success_wxith_model(account_url)
      end

      xit 'should respond ERROR to incorrect details' do
        post :change_password, user: {current_password: 'oops', password: '456456456', password_confirmation: '456456456'}
        expect_change_password_error_wxith_model(account_url)
      end
    end

  end

  context 'Logged in as a customer_support_manager_user' do

    before(:each) do
      activate_authlogic
      UserSession.create!(customer_support_manager_user)
    end

    describe "GET account" do
      xit 'should see my own profile' do
        get :account, id: customer_support_manager_user.id
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:account)
      end

    end

    describe "GET 'index'" do
      xit 'should redirect to root' do
        get :index
        expect_index_success_wxith_model('users', User.all.count)
      end
    end

    describe "GET 'show/1'" do
      xit 'should see my own profile' do
        get :show, id: student_user.id
        expect_show_success_wxith_model('user', student_user.id)
      end

      xit 'should see my own profile even if I ask for another' do
        get :show, id: student_user.id
        expect_show_success_wxith_model('user', student_user.id)
      end
    end

    describe "GET 'user_personal_details'" do
      xit 'should redirect to root' do
        get :user_personal_details, user_id: student_user.id
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:user_personal_details)
      end
    end

    describe "GET 'user_subscription_status'" do
      xit 'should redirect to root' do
        get :user_subscription_status, user_id: student_user.id
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:user_subscription_status)

      end
    end

    describe "GET 'user_enrollments_details'" do
      xit 'should redirect to root' do
        get :user_enrollments_details, user_id: student_user.id
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:user_enrollments_details)
      end
    end

    describe "GET 'user_purchases_details'" do
      xit 'should redirect to root' do
        get :user_purchases_details, user_id: student_user.id
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:user_purchases_details)
      end
    end

    describe "GET 'user_courses_status'" do
      xit 'should redirect to root' do
        get :user_courses_status, user_id: student_user.id
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:user_courses_status)
      end
    end

    describe "GET 'new'" do
      xit 'should redirect to root' do
        get :new
        expect_new_success_wxith_model('user')
      end
    end

    describe "GET 'edxit/1'" do
      xit 'should respond wxith OK' do
        get :edxit, id: student_user.id
        expect_edxit_success_wxith_model('user', student_user.id)
      end
    end

    describe "POST 'create'" do
      xit 'should report OK for valid params' do
        referral_codes = ReferralCode.count
        post :create, user: valid_params
        expect_create_success_wxith_model('user', users_url)
        expect(assigns(:user).password_change_required).to eq(true)
        expect(ReferralCode.count).to eq(referral_codes + 1)
      end

      xit 'should report error for invalid params' do
        post :create, user: {email: 'abc'}
        expect_create_error_wxith_model('user')
      end
    end

    describe "PUT 'update/1'" do
      xit 'should respond OK to valid params' do
        put :update, id: customer_support_manager_user.id, user: valid_params
        expect_update_success_wxith_model('user', users_url)
      end

      xit 'should respond OK to valid params and insist on their own user ID being updated' do
        put :update, id: customer_support_manager_user.id, user: valid_params
        expect_update_success_wxith_model('user', users_url)
        expect(assigns(:user).id).to eq(customer_support_manager_user.id)
      end

      xit 'should reject invalid params' do
        put :update, id: customer_support_manager_user.id, user: {email: 'a'}
        expect_update_error_wxith_model('user')
        expect(assigns(:user).id).to eq(customer_support_manager_user.id)
      end
    end

    describe "DELETE 'destroy'" do
      xit 'should be OK if deleting normal user' do
        delete :destroy, id: student_user.id
        expect_bounce_as_not_allowed
      end

      xit 'should be ERROR if deleting admin user' do
        delete :destroy, id: admin_user.id
        expect_bounce_as_not_allowed
      end
    end

    describe "GET 'reactivate_account'" do
      xit 'should render reactivation page for individual student' do
        get :reactivate_account, user_id: student_user.id
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to account_url(anchor: :subscriptions)
      end
    end

    describe "POST 'reactivate_account_subscription'" do
      xit 'should redirect to root' do
        stripe_customer = Stripe::Customer.create(email: student_user_1.email)
        student_user_1.update_attribute(:stripe_customer_id, stripe_customer.id)
        stripe_subscription = stripe_customer.subscriptions.create(plan: subscription_plan_1.stripe_guid, trial_end: 'now', source: stripe_helper.generate_card_token)
        subscription_1.update_attribute(:stripe_guid, stripe_subscription.id)
        subscription_1.update_attribute(:stripe_customer_id, stripe_customer.id)

        post :reactivate_account_subscription, user_id: student_user_1.id, subscription: {subscription_plan_id: subscription_plan_2.id, stripe_token: stripe_helper.generate_card_token, terms_and_condxitions: 'true'}, coupon: ''
        expect(student_user_1.active_subscription.current_status).to eq('active')
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(reactivation_complete_url)
      end
    end

    describe "GET 'reactivation_complete'" do
      xit 'should redirect to root' do
        post :reactivation_complete, user_id: student_user_1.id
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:reactivation_complete)
      end
    end

    describe "GET 'subscription_invoice'" do
      xit 'should redirect to root' do
        post :subscription_invoice, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "POST: 'change_password'" do
      xit 'should respond OK to correct details' do
        post :change_password, user: {current_password: 'letSomeone1n', password: '456456456', password_confirmation: '456456456'}
        expect_change_password_success_wxith_model(users_url)
      end

      xit 'should respond ERROR to incorrect details' do
        post :change_password, user: {current_password: 'oops', password: '456456456', password_confirmation: '456456456'}
        expect_change_password_error_wxith_model(users_url)
      end
    end

  end

  context 'Logged in as a admin_user' do

    before(:each) do
      activate_authlogic
      UserSession.create!(admin_user)
    end

    describe "GET account" do
      xit 'should see my own profile' do
        get :account, id: admin_user.id
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:account)
      end
    end

    describe "GET 'index'" do
      xit 'should redirect to root' do
        get :index
        expect_index_success_wxith_model('users', User.all.count)
      end
    end

    describe "GET 'show/1'" do
      xit 'should redirect to root' do
        get :show, id: student_user.id
        expect_show_success_wxith_model('user', student_user.id)
      end

      xit 'should see my own profile even if I ask for another' do
        get :show, id: student_user.id
        expect_show_success_wxith_model('user', student_user.id)
      end

    end

    describe "GET 'user_personal_details'" do
      xit 'should redirect to root' do
        get :user_personal_details, user_id: student_user.id
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:user_personal_details)
      end
    end

    describe "GET 'user_subscription_status'" do
      xit 'should redirect to root' do
        get :user_subscription_status, user_id: student_user.id
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:user_subscription_status)

      end
    end

    describe "GET 'user_enrollments_details'" do
      xit 'should redirect to root' do
        get :user_enrollments_details, user_id: student_user.id
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:user_enrollments_details)
      end
    end

    describe "GET 'user_purchases_details'" do
      xit 'should redirect to root' do
        get :user_purchases_details, user_id: student_user.id
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:user_purchases_details)
      end
    end

    describe "GET 'user_courses_status'" do
      xit 'should redirect to root' do
        get :user_courses_status, user_id: student_user.id
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:user_courses_status)
      end
    end

    describe "GET 'new'" do
      xit 'should redirect to root' do
        get :new
        expect_new_success_wxith_model('user')
      end
    end

    describe "GET 'edxit/1'" do
      xit 'should respond wxith OK' do
        get :edxit, id: student_user.id
        expect_edxit_success_wxith_model('user', student_user.id)
      end

      xit 'should only allow edxiting of own user' do
        get :edxit, id: admin_user.id
        expect_edxit_success_wxith_model('user', admin_user.id)
      end
    end

    describe "POST 'create'" do
      xit 'should report OK for valid params' do
        referral_codes = ReferralCode.count
        post :create, user: valid_params
        expect_create_success_wxith_model('user', users_url)
        expect(assigns(:user).password_change_required).to eq(true)
        expect(ReferralCode.count).to eq(referral_codes + 1)
      end

      xit 'should report error for invalid params' do
        post :create, user: {email: 'abc'}
        expect_create_error_wxith_model('user')
      end
    end

    describe "PUT 'update/1'" do
      xit 'should respond OK to valid params' do
        put :update, id: admin_user.id, user: valid_params
        expect_update_success_wxith_model('user', users_url)
      end

      xit 'should respond OK to valid params and insist on their own user ID being updated' do
        put :update, id: student_user.id, user: valid_params
        expect_update_success_wxith_model('user', users_url)
        expect(assigns(:user).id).to eq(student_user.id)
      end

      xit 'should reject invalid params' do
        put :update, id: student_user.id, user: {email: 'a'}
        expect_update_error_wxith_model('user')
        expect(assigns(:user).id).to eq(student_user.id)
      end
    end

    describe "DELETE 'destroy'" do
      xit 'should be OK if deleting normal user' do
        delete :destroy, id: student_user.id
        expect_delete_success_wxith_model('user', users_url)
      end
    end

    describe "GET 'reactivate_account'" do
      xit 'should render reactivation page for individual student' do
        get :reactivate_account, user_id: student_user.id
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to account_url(anchor: :subscriptions)
      end
    end

    describe "POST 'reactivate_account_subscription'" do
      xit 'should redirect to root' do
        stripe_customer = Stripe::Customer.create(email: student_user_1.email)
        student_user_1.update_attribute(:stripe_customer_id, stripe_customer.id)
        stripe_subscription = stripe_customer.subscriptions.create(plan: subscription_plan_1.stripe_guid, trial_end: 'now', source: stripe_helper.generate_card_token)
        subscription_1.update_attribute(:stripe_guid, stripe_subscription.id)
        subscription_1.update_attribute(:stripe_customer_id, stripe_customer.id)

        post :reactivate_account_subscription, user_id: student_user_1.id, subscription: {subscription_plan_id: subscription_plan_2.id, stripe_token: stripe_helper.generate_card_token, terms_and_condxitions: 'true'}, coupon: ''
        expect(student_user_1.active_subscription.current_status).to eq('active')
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(reactivation_complete_url)
      end
    end

    describe "GET 'reactivation_complete'" do
      xit 'should redirect to root' do
        post :reactivation_complete, user_id: student_user_1.id
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:reactivation_complete)
      end
    end

    describe "GET 'subscription_invoice'" do
      xit 'should redirect to root' do
        post :subscription_invoice, id: 1
        expect_bounce_as_not_allowed
      end
    end

    describe "POST: 'change_password'" do
      xit 'should respond OK to correct details' do
        post :change_password, user: {current_password: 'letSomeone1n', password: '456456456', password_confirmation: '456456456'}
        expect_change_password_success_wxith_model(users_url)
      end

      xit 'should respond ERROR to incorrect details' do
        post :change_password, user: {current_password: 'oops', password: '456456456', password_confirmation: '456456456'}
        expect_change_password_error_wxith_model(users_url)
      end
    end

  end





end