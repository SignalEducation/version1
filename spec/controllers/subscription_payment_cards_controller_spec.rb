# == Schema Information
#
# Table name: subscription_payment_cards
#
#  id                  :integer          not null, primary key
#  user_id             :integer
#  stripe_card_guid    :string
#  status              :string
#  brand               :string
#  last_4              :string
#  expiry_month        :integer
#  expiry_year         :integer
#  address_line1       :string
#  account_country     :string
#  account_country_id  :integer
#  created_at          :datetime
#  updated_at          :datetime
#  stripe_object_name  :string
#  funding             :string
#  cardholder_name     :string
#  fingerprint         :string
#  cvc_checked         :string
#  address_line1_check :string
#  address_zip_check   :string
#  dynamic_last4       :string
#  customer_guid       :string
#  is_default_card     :boolean          default(FALSE)
#  address_line2       :string
#  address_city        :string
#  address_state       :string
#  address_zip         :string
#  address_country     :string
#

require 'rails_helper'
require 'support/users_and_groups_setup'
require 'support/subscription_plans_setup'
require 'stripe_mock'

RSpec.describe SubscriptionPaymentCardsController, type: :controller do

  include_context 'users_and_groups_setup'
  include_context 'subscription_plans_setup'
  include_context 'system_setup'

  before { StripeMock.start }
  after { StripeMock.stop }

  let(:stripe_helper) { StripeMock.create_test_helper }
  let(:card_params) { { last4: '4242', exp_mth: 12, exp_year: 2019 } }
  let(:bad_card_params) { { last4: '4241', exp_mth: 12, exp_year: 2012 } }
  let(:stripe_card_token) { stripe_helper.generate_card_token(card_params) }
  let(:stripe_bad_token) { StripeMock.prepare_card_error(:incorrect_number) }

  let(:individual_student_user_2) { FactoryGirl.create(:individual_student_user)}
  let!(:stripe_customer_1) { customer = Stripe::Customer.create({
                  email: individual_student_user.email,
                  card: stripe_helper.generate_card_token})
                  individual_student_user.stripe_customer_id = customer.id
                  individual_student_user.save!
                  customer
  }
  let!(:stripe_customer_2) { customer = Stripe::Customer.create({
                  email: individual_student_user_2.email,
                  card: stripe_helper.generate_card_token})
  individual_student_user_2.stripe_customer_id = customer.id
  individual_student_user_2.save!
                  customer
  }

  let(:card_1) { FactoryGirl.create(:subscription_payment_card,
                  stripe_token: stripe_helper.generate_card_token(card_params),
                  user_id: individual_student_user.id,
                  customer_guid: individual_student_user.stripe_customer_id) }
  let(:card_2) { FactoryGirl.create(:subscription_payment_card,
                  stripe_token: stripe_helper.generate_card_token(card_params),
                  user_id: individual_student_user_2.id,
                  customer_guid: individual_student_user_2.stripe_customer_id) }
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
        user_card_count = individual_student_user.subscription_payment_cards.count
        post :create, subscription_payment_card: create_params.merge(user_id: individual_student_user.id)
        expect(individual_student_user.subscription_payment_cards.count).to eq(user_card_count + 1)
        expect(flash[:error]).to eq(nil)
        expect(flash[:success]).to eq(I18n.t('controllers.subscription_payment_cards.create.flash.success'))
        expect(response.status).to eq(302)
        expect(response).to redirect_to(account_url(anchor: 'payment-details'))
      end

      it 'should report ERROR as token is invalid' do
        post :create, subscription_payment_card: {stripe_token: stripe_bad_token, user_id: individual_student_user.id, make_default_card: true}
        expect(flash[:error]).to eq(I18n.t('controllers.subscription_payment_cards.create.flash.error'))
        expect(flash[:success]).to eq(nil)
        expect(response.status).to eq(302)
        expect(response).to redirect_to(account_url(anchor: 'payment-details'))
      end
    end

    describe "PUT 'update'" do
      it 'should be OK with redirect' do
        put :update, id: card_1.id
        expect(flash[:error]).to eq(nil)
        expect(flash[:success]).to eq(I18n.t('controllers.subscription_payment_cards.update.flash.success'))
        expect(response.status).to eq(302)
        expect(response).to redirect_to(account_url(anchor: 'payment-details'))
      end
    end
  end

  context 'Logged in as complimentary_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(comp_user)
    end

    describe "POST 'create'" do
      it 'should be OK with redirect' do
        post :create, subscription_payment_card: create_params.merge(user_id: individual_student_user.id)
        expect_bounce_as_not_allowed
      end

      it 'should report ERROR as token is invalid' do
        post :create, subscription_payment_card: {stripe_token: stripe_bad_token, user_id: individual_student_user.id, make_default_card: true}
        expect_bounce_as_not_allowed
      end
    end

    describe "PUT 'update'" do
      it 'should be OK with redirect' do
        put :update, id: card_1.id
        expect_bounce_as_not_allowed
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

  context 'Logged in as a customer_support_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(customer_support_manager_user)
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

  context 'Logged in as a marketing_manager_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(marketing_manager_user)
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
        expect(response).to redirect_to(account_url(anchor: 'payment-details'))
      end

      it 'should report ERROR as token is invalid' do
        post :create, subscription_payment_card: {stripe_token: stripe_bad_token, user_id: individual_student_user_2.id, make_default_card: true}
        expect(flash[:error]).to eq(I18n.t('controllers.subscription_payment_cards.create.flash.error'))
        expect(flash[:success]).to eq(nil)
        expect(response.status).to eq(302)
        expect(response).to redirect_to(account_url(anchor: 'payment-details'))
      end
    end

    describe "PUT 'update'" do
      it 'should be OK with redirect' do
        put :update, id: card_1.id
        expect(flash[:error]).to eq(nil)
        expect(flash[:success]).to eq(I18n.t('controllers.subscription_payment_cards.update.flash.success'))
        expect(response.status).to eq(302)
        expect(response).to redirect_to(account_url(anchor: 'payment-details'))
      end
    end
  end

end
