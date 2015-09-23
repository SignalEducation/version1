require 'rails_helper'
require 'support/users_and_groups_setup'
require 'support/subscription_plans_setup'
require 'stripe_mock'

RSpec.describe SubscriptionPaymentCardsController, type: :controller do

  include_context 'users_and_groups_setup'
  include_context 'subscription_plans_setup'

  before { StripeMock.start }
  after { StripeMock.stop }

  let(:card_params) { { last4: '4242', exp_mth: 12, exp_year: 2019 } }
  let(:bad_card_params) { { last4: '4241', exp_mth: 12, exp_year: 2012 } }
  let(:stripe_card_token) { stripe_helper.generate_card_token(card_params) }
  let(:stripe_bad_token) { StripeMock.prepare_card_error(:incorrect_number) }

  let!(:stripe_customer_1) { customer = Stripe::Customer.create({
                  email: individual_student_user.email,
                  card: stripe_helper.generate_card_token})
                  individual_student_user.stripe_customer_id = customer.id
                  individual_student_user.save!
                  customer
  }
  let!(:stripe_customer_2) { customer = Stripe::Customer.create({
                  email: corporate_customer_user.email,
                  card: stripe_helper.generate_card_token})
                  corporate_customer_user.stripe_customer_id = customer.id
                  corporate_customer_user.save!
                  customer
  }

  let(:card_1) { FactoryGirl.create(:subscription_payment_card,
                  stripe_token: stripe_helper.generate_card_token(card_params),
                  user_id: individual_student_user.id,
                  customer_guid: individual_student_user.stripe_customer_id) }
  let(:card_2) { FactoryGirl.create(:subscription_payment_card,
                  stripe_token: stripe_helper.generate_card_token(card_params),
                  user_id: corporate_customer_user.id,
                  customer_guid: corporate_customer_user.stripe_customer_id) }
  let!(:create_params) { {stripe_token: stripe_card_token, make_default_card: true} }
                  # needs a user_id too


  context 'Not logged in' do
    describe 'POST create: ' do
      it 'should redirect to root' do
        post :create, subscription_payment_card: create_params
        expect_bounce_as_not_signed_in
      end
    end

    describe "PUT 'update/1'" do
      it 'should redirect to root' do
        put :update, id: 1
        expect_bounce_as_not_signed_in
      end
    end
  end

  context 'Logged in as individual_student: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(individual_student_user)
    end

    describe "POST 'create'" do
      it 'should be OK with redirect' do
        post :create, subscription_payment_card: create_params.merge(user_id: individual_student_user.id)
        expect(flash[:error]).to eq(nil)
        expect(flash[:success]).to eq(I18n.t('controllers.subscription_payment_cards.create.flash.success'))
        expect(response.status).to eq(302)
        expect(response).to redirect_to(account_url(anchor: 'subscriptions'))
      end

      it 'should report ERROR as token is invalid' do
        post :create, subscription_payment_card: {stripe_token: stripe_bad_token, user_id: individual_student_user.id, make_default_card: true}
        expect(flash[:error]).to eq(I18n.t('controllers.subscription_payment_cards.create.flash.error'))
        expect(flash[:success]).to eq(nil)
        expect(response.status).to eq(302)
        expect(response).to redirect_to(account_url(anchor: 'subscriptions'))
      end
    end

    describe "PUT 'update'" do
      it 'should be OK with redirect' do
        put :update, id: card_1.id
        expect(flash[:error]).to eq(nil)
        expect(flash[:success]).to eq(I18n.t('controllers.subscription_payment_cards.update.flash.success'))
        expect(response.status).to eq(302)
        expect(response).to redirect_to(account_url(anchor: 'subscriptions'))
      end
    end
  end

  context 'Logged in as a tutor_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(tutor_user)
    end

    describe "POST 'create'" do
      it 'expect ERROR as not allowed' do
        post :create, subscription_payment_card: {}
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update'" do
      it 'expect ERROR as not allowed' do
        put :update, id: 1
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a corporate_student_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(corporate_student_user)
    end

    describe "POST 'create'" do
      it 'expect ERROR as not allowed' do
        post :create, subscription_payment_card: {}
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update'" do
      it 'expect ERROR as not allowed' do
        put :update, id: 1
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as corporate_customer_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(corporate_customer_user)
    end

    describe "POST 'create'" do
      it 'should be OK with redirect' do
        post :create, subscription_payment_card: create_params.merge(user_id: corporate_customer_user.id)
        expect(flash[:error]).to eq(nil)
        expect(flash[:success]).to eq(I18n.t('controllers.subscription_payment_cards.create.flash.success'))
        expect(response.status).to eq(302)
        expect(response).to redirect_to(account_url(anchor: 'subscriptions'))
      end

      it 'should report ERROR as token is invalid' do
        post :create, subscription_payment_card: {stripe_token: stripe_bad_token, user_id: corporate_customer_user.id, make_default_card: true}
        expect(flash[:error]).to eq(I18n.t('controllers.subscription_payment_cards.create.flash.error'))
        expect(flash[:success]).to eq(nil)
        expect(response.status).to eq(302)
        expect(response).to redirect_to(account_url(anchor: 'subscriptions'))
      end
    end

    describe "PUT 'update'" do
      it 'should be OK with redirect' do
        put :update, id: card_2.id
        expect(flash[:error]).to eq(nil)
        expect(flash[:success]).to eq(I18n.t('controllers.subscription_payment_cards.update.flash.success'))
        expect(response.status).to eq(302)
        expect(response).to redirect_to(account_url(anchor: 'subscriptions'))
      end
    end
  end

  context 'Logged in as a blogger_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(blogger_user)
    end

    describe "POST 'create'" do
      it 'expect ERROR as not allowed' do
        post :create, subscription_payment_card: {}
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update'" do
      it 'expect ERROR as not allowed' do
        put :update, id: 1
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a forum_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(forum_manager_user)
    end

    describe "POST 'create'" do
      it 'expect ERROR as not allowed' do
        post :create, subscription_payment_card: {}
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update'" do
      it 'expect ERROR as not allowed' do
        put :update, id: 1
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as a content_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(content_manager_user)
    end

    describe "POST 'create'" do
      it 'expect ERROR as not allowed' do
        post :create, subscription_payment_card: {}
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update'" do
      it 'expect ERROR as not allowed' do
        put :update, id: 1
        expect_bounce_as_not_allowed
      end
    end

  end

  context 'Logged in as admin_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(admin_user)
    end

    describe "POST 'create'" do
      it 'should be OK with redirect' do
        post :create, subscription_payment_card: create_params.merge(user_id: individual_student_user.id)
        expect(flash[:error]).to eq(nil)
        expect(flash[:success]).to eq(I18n.t('controllers.subscription_payment_cards.create.flash.success'))
        expect(response.status).to eq(302)
        expect(response).to redirect_to(account_url(anchor: 'subscriptions'))
      end

      it 'should report ERROR as token is invalid' do
        post :create, subscription_payment_card: {stripe_token: stripe_bad_token, user_id: corporate_customer_user.id, make_default_card: true}
        expect(flash[:error]).to eq(I18n.t('controllers.subscription_payment_cards.create.flash.error'))
        expect(flash[:success]).to eq(nil)
        expect(response.status).to eq(302)
        expect(response).to redirect_to(account_url(anchor: 'subscriptions'))
      end
    end

    describe "PUT 'update'" do
      it 'should be OK with redirect' do
        put :update, id: card_1.id
        expect(flash[:error]).to eq(nil)
        expect(flash[:success]).to eq(I18n.t('controllers.subscription_payment_cards.update.flash.success'))
        expect(response.status).to eq(302)
        expect(response).to redirect_to(account_url(anchor: 'subscriptions'))
      end
    end
  end

end
