# == Schema Information
#
# Table name: subscriptions
#
#  id                       :integer          not null, primary key
#  user_id                  :integer
#  subscription_plan_id     :integer
#  stripe_guid              :string
#  next_renewal_date        :date
#  complimentary            :boolean          default(FALSE), not null
#  stripe_status            :string
#  created_at               :datetime
#  updated_at               :datetime
#  stripe_customer_id       :string
#  stripe_customer_data     :text
#  livemode                 :boolean          default(FALSE)
#  active                   :boolean          default(FALSE)
#  terms_and_conditions     :boolean          default(FALSE)
#  coupon_id                :integer
#  paypal_subscription_guid :string
#  paypal_token             :string
#  paypal_status            :string
#  state                    :string
#

require 'rails_helper'
require 'support/users_and_groups_setup'
require 'support/system_setup'
require 'stripe_mock'

describe SubscriptionsController, type: :controller do

  include_context 'users_and_groups_setup'
  include_context 'system_setup'

  let(:stripe_helper) { StripeMock.create_test_helper }
  let!(:start_stripe_mock) { StripeMock.start }
  let!(:subscription_plan_1) { FactoryBot.create(:student_subscription_plan) }
  let!(:subscription_plan_2) { FactoryBot.create(:student_subscription_plan) }
  let!(:student_user_2) { FactoryBot.create(:student_user, country_id: Country.first.id) }
  let!(:student_user_3) { FactoryBot.create(:student_user, country_id: Country.first.id) }
  let!(:subscription_payment_card) { FactoryBot.create(:subscription_payment_card, user_id: student_user.id) }
  let!(:subscription_1) { x = FactoryBot.create(:subscription,
                             user_id: valid_subscription_student.id,
                             active: true,
                             subscription_plan_id: subscription_plan_1.id,
                             stripe_token: stripe_helper.generate_card_token)
  valid_subscription_student.stripe_customer_id = x.stripe_customer_id
  valid_subscription_student.save
                             x }
  let!(:subscription_2) { x = FactoryBot.create(:subscription,
                             user_id: student_user_2.id,
                             subscription_plan_id: subscription_plan_1.id,
                             stripe_token: stripe_helper.generate_card_token)
  student_user_2.stripe_customer_id = x.stripe_customer_id
  student_user_2.save
                             x }
  let!(:subscription_3) { x = FactoryBot.create(:subscription,
                             user_id: student_user_3.id,
                             subscription_plan_id: subscription_plan_1.id,
                             stripe_token: stripe_helper.generate_card_token)}


  let!(:upgrade_params) {{ subscriptions_attributes: { "0" => {subscription_plan_id: subscription_plan_1.id, stripe_token: stripe_helper.generate_card_token, terms_and_conditions: 'true'} } }}
  let!(:invalid_upgrade_params) {{ subscriptions_attributes: { "0" => {subscription_plan_id: subscription_plan_1.id, stripe_token: stripe_helper.generate_card_token, terms_and_conditions: 'false'} } }}

  let!(:valid_params) { {subscription_plan_id: subscription_plan_2.id} }

  after { StripeMock.stop }

  context 'Logged in as a valid_trial_student: ' do

    ##TODO
    ## Testing for student users must test each account type a user can have
    ## [not-started-trial, valid-trial, expired-trial]
    ## [valid-sub, past-due-sub, canceled-pending-sub, canceled-sub]
    ##TODO

    before(:each) do
      activate_authlogic
      UserSession.create!(valid_trial_student)
      stripe_plan = Stripe::Plan.create(
          amount: (subscription_plan_1.price.to_f * 100).to_i,
          interval: 'month',
          interval_count: subscription_plan_1.payment_frequency_in_months.to_i,
          trial_period_days: subscription_plan_1.trial_period_in_days.to_i,
          name: 'LearnSignal ' + subscription_plan_1.name.to_s,
          statement_descriptor: 'LearnSignal',
          currency: subscription_plan_1.currency.try(:iso_code).try(:downcase),
          id: Rails.env + '-' + ApplicationController::generate_random_code(20)
      )
      subscription_plan_1.update_attribute(:stripe_guid, stripe_plan.id)
      stripe_customer = Stripe::Customer.create(
          email: valid_trial_student.email
      )
      valid_trial_student.update_attributes(stripe_customer_id: stripe_customer.id, country_id: Country.first.id)

      valid_coupon = Stripe::Coupon.create(percent_off: 25, duration: 'repeating', duration_in_months: 3, id: 'valid_coupon_code', currency: subscription_plan_1.currency.try(:iso_code).try(:downcase))
    end

    describe "GET 'new'" do
      xit 'should render upgrade page' do
        get :new
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:new)
      end
    end

    describe "POST 'create'" do
      xit 'should respond okay with correct params and valid coupon' do
        expect(SubscriptionTransaction.count).to eq(0)
        expect(SubscriptionPaymentCard.count).to eq(1)
        post :create, user: upgrade_params, hidden_coupon_code: 'valid_coupon_code', user_id: student_user.id
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to personal_upgrade_complete_url
        expect(SubscriptionTransaction.count).to eq(1)
        expect(SubscriptionPaymentCard.count).to eq(2)
      end

      xit 'should respond with Error coupon is invalid' do
        post :create, user: upgrade_params, hidden_coupon_code: 'abc123', user_id: student_user.id
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to eq('The coupon code entered is not valid')
        expect(response.status).to eq(302)
        expect(response).to redirect_to(new_url(coupon: true))
        expect(SubscriptionTransaction.count).to eq(0)
        expect(SubscriptionPaymentCard.count).to eq(1)

      end

      xit 'should respond okay with correct params without coupon' do
        expect(SubscriptionTransaction.count).to eq(0)
        expect(SubscriptionPaymentCard.count).to eq(1)
        post :create, user: upgrade_params, hidden_coupon_code: '', user_id: student_user.id
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to personal_upgrade_complete_url
        expect(SubscriptionTransaction.count).to eq(1)
        expect(SubscriptionPaymentCard.count).to eq(2)
      end

      xit 'should respond with Error Your request was declined. With Bad params' do
        post :create, user: invalid_upgrade_params, hidden_coupon_code: 'valid_coupon_code', user_id: student_user.id
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to eq('Sorry! Your request was declined. Please check that all details are valid and try again. Or contact us for assistance.')
        expect(response.status).to eq(302)
        expect(response).to redirect_to(new_url)
        expect(SubscriptionTransaction.count).to eq(0)
        expect(SubscriptionPaymentCard.count).to eq(1)
      end

    end

    describe "GET 'personal_upgrade_complete'" do
      xit 'should render upgrade complete page' do
        get :personal_upgrade_complete
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:personal_upgrade_complete)
      end
    end

    describe "Get 'change_plan'" do
      xit 'should successfully render the change_plan form' do
        get :change_plan
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:change_plan)
      end
    end

    describe "PUT 'update/1'" do
      xit 'should create a new subscription then redirect to account' do
        stripe_customer = Stripe::Customer.create(email: student_user.email)
        student_user.update_attribute(:stripe_customer_id, stripe_customer.id)
        stripe_subscription = stripe_customer.subscriptions.create(plan: subscription_plan_1.stripe_guid, trial_end: 'now', source: stripe_helper.generate_card_token)
        subscription_1.update_attribute(:stripe_guid, stripe_subscription.id)
        subscription_1.update_attribute(:stripe_customer_id, stripe_customer.id)
        subscription_1.update_attribute(:stripe_customer_data, stripe_customer.to_hash.deep_dup)

        put :update, id: subscription_1.id, subscription: valid_params
        old_sub = Subscription.find(subscription_1.id)
        expect(old_sub.current_status).to eq('canceled')
        expect(student_user.current_subscription.id).not_to eq(old_sub.id)
        expect(student_user.current_subscription.current_status).to eq('active')
        expect(student_user.current_subscription.subscription_plan_id).to eq(subscription_plan_2.id)

        expect(flash[:success]).to eq(I18n.t('controllers.subscriptions.update.flash.success'))
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to account_url(anchor: 'subscriptions')
      end

      xit 'should fail to create a new subscription then redirect to account' do
        stripe_customer = Stripe::Customer.create(email: student_user.email)
        student_user.update_attribute(:stripe_customer_id, stripe_customer.id)
        stripe_subscription = stripe_customer.subscriptions.create(plan: subscription_plan_1.stripe_guid, trial_end: 'now', source: stripe_helper.generate_card_token)
        subscription_1.update_attribute(:stripe_guid, stripe_subscription.id)
        subscription_1.update_attribute(:stripe_customer_id, stripe_customer.id)
        subscription_1.update_attribute(:stripe_customer_data, stripe_customer.to_hash.deep_dup)
        subscription_1.update_attribute(:current_status, 'canceled')

        put :update, id: subscription_1.id, subscription: valid_params

        expect(flash[:success]).to be_nil
        expect(flash[:error]).to eq(I18n.t('controllers.subscriptions.update.flash.error'))
        expect(response.status).to eq(302)
        expect(response).to redirect_to account_url(anchor: 'subscriptions')
      end
    end

    describe "DELETE 'destroy'" do
      xit 'should redirect to account page updating to canceled-pending' do
        stripe_customer = Stripe::Customer.create(email: student_user_3.email)
        student_user_3.update_attribute(:stripe_customer_id, stripe_customer.id)
        stripe_subscription = stripe_customer.subscriptions.create(plan: subscription_plan_1.stripe_guid, trial_end: 'now', source: stripe_helper.generate_card_token)
        subscription_3.update_attribute(:stripe_guid, stripe_subscription.id)
        subscription_3.update_attribute(:stripe_customer_id, stripe_customer.id)
        subscription_3.update_attribute(:stripe_customer_data, stripe_customer.to_hash.deep_dup)
        expect(subscription_3.current_status).to eq('active')

        delete :destroy, id: subscription_3.id
        sub = Subscription.find(subscription_3.id)
        expect(sub.current_status).to eq('canceled-pending')
        expect(flash[:success]).to eq(I18n.t('controllers.subscriptions.destroy.flash.success'))
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to account_url(anchor: 'subscriptions')
      end
    end

  end

end
