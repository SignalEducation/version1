require 'rails_helper'
require 'support/users_and_groups_setup'
require 'support/subscription_plans_setup'
require 'stripe_mock'

RSpec.describe StudentSignUpsController, type: :controller do

  include_context 'users_and_groups_setup'
  include_context 'subscription_plans_setup'

  #### Needed for Stripe-Ruby-Mocks
  #let(:stripe_helper) { StripeMock.create_test_helper }
  let(:card_params) { { last4: '4242', exp_mth: 12, exp_year: 2019 } }
  let(:stripe_card_token) { stripe_helper.generate_card_token(card_params) }
  before { StripeMock.start }
  after { StripeMock.stop }

  let!(:sub_plan) { FactoryGirl.create(:subscription_plan, currency_id: eur.id, price: 14.99) }
  let!(:valid_params) { {email: 'new-user@example.com',
                         first_name: 'Joe', last_name: 'Smith', locale: 'en',
                         password: '123123123', password_confirmation: '123123123',
                         country_id: ireland.id, user_group_id: 1,
                         subscriptions_attributes: [
                              subscription_plan_id: sub_plan.id,
                              stripe_token: stripe_card_token
                         ]
                        }
  }
  let!(:invalid_params) { FactoryGirl.attributes_for(:individual_student_user, email: '') }

  context 'Not logged in' do
    describe "GET 'new'" do
      it 'returns http success' do
        get :new
        expect_new_success_with_model('user')
        expect(assigns(:user).subscriptions.first.subscription_plan_id).to eq(SubscriptionPlan.first.id)
      end
    end

    describe "POST 'create'" do
      it 'returns http success' do
        post :create, user: valid_params
        expect_create_success_with_model('user', personal_sign_up_complete_url(assigns(:user).guid), I18n.t('controllers.student_sign_ups.create.flash.success'))
        expect(Subscription.all.count).to eq(1)
        expect(assigns(:user).subscriptions.count).to eq(1)
      end

      it 'returns bad input to the new page' do
        post :create, user: invalid_params
        expect_create_error_with_model('user')
      end
    end

  end

  context 'Logged in as a individual_student_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(individual_student_user)
    end

    describe "GET 'new'" do
      it 'should redirect to sign_in' do
        get :new
        expect_bounce_as_signed_in
      end
    end

    describe "POST 'create'" do
      it 'should redirect to sign_in' do
        post :create, user: valid_params
        expect_bounce_as_signed_in
      end
    end

  end

  context 'Logged in as a tutor_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(tutor_user)
    end

    describe "GET 'new'" do
      it 'should redirect to sign_in' do
        get :new
        expect_bounce_as_signed_in
      end
    end

    describe "POST 'create'" do
      it 'should redirect to sign_in' do
        post :create, user: valid_params
        expect_bounce_as_signed_in
      end
    end

  end

  context 'Logged in as a corporate_student_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(corporate_student_user)
    end

    describe "GET 'new'" do
      it 'should redirect to sign_in' do
        get :new
        expect_bounce_as_signed_in
      end
    end

    describe "POST 'create'" do
      it 'should redirect to sign_in' do
        post :create, user: valid_params
        expect_bounce_as_signed_in
      end
    end

  end

  context 'Logged in as a corporate_customer_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(corporate_customer_user)
    end

    describe "GET 'new'" do
      it 'should redirect to sign_in' do
        get :new
        expect_bounce_as_signed_in
      end
    end

    describe "POST 'create'" do
      it 'should redirect to sign_in' do
        post :create, user: valid_params
        expect_bounce_as_signed_in
      end
    end

  end

  context 'Logged in as a blogger_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(blogger_user)
    end

    describe "GET 'new'" do
      it 'should redirect to sign_in' do
        get :new
        expect_bounce_as_signed_in
      end
    end

    describe "POST 'create'" do
      it 'should redirect to sign_in' do
        post :create, user: valid_params
        expect_bounce_as_signed_in
      end
    end

  end

  context 'Logged in as a forum_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(forum_manager_user)
    end

    describe "GET 'new'" do
      it 'should redirect to sign_in' do
        get :new
        expect_bounce_as_signed_in
      end
    end

    describe "POST 'create'" do
      it 'should redirect to sign_in' do
        post :create, user: valid_params
        expect_bounce_as_signed_in
      end
    end

  end

  context 'Logged in as a content_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(content_manager_user)
    end

    describe "GET 'new'" do
      it 'should redirect to sign_in' do
        get :new
        expect_bounce_as_signed_in
      end
    end

    describe "POST 'create'" do
      it 'should redirect to sign_in' do
        post :create, user: valid_params
        expect_bounce_as_signed_in
      end
    end

  end

  context 'Logged in as a admin_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(admin_user)
    end

    describe "GET 'new'" do
      it 'should redirect to sign_in' do
        get :new
        expect_bounce_as_signed_in
      end
    end

    describe "POST 'create'" do
      it 'should redirect to sign_in' do
        post :create, user: valid_params
        expect_bounce_as_signed_in
      end
    end

  end

end
