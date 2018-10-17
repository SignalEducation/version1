# == Schema Information
#
# Table name: subscriptions
#
#  id                   :integer          not null, primary key
#  user_id              :integer
#  subscription_plan_id :integer
#  stripe_guid          :string
#  next_renewal_date    :date
#  complimentary        :boolean          default(FALSE), not null
#  current_status       :string
#  created_at           :datetime
#  updated_at           :datetime
#  stripe_customer_id   :string
#  stripe_customer_data :text
#  livemode             :boolean          default(FALSE)
#  active               :boolean          default(FALSE)
#  terms_and_conditions :boolean          default(FALSE)
#  coupon_id            :integer
#

require 'rails_helper'

describe SubscriptionsController, type: :controller do

  let!(:gbp) { FactoryBot.create(:gbp) }
  let!(:uk) { FactoryBot.create(:uk, currency_id: gbp.id) }
  let!(:uk_vat_code) { FactoryBot.create(:vat_code, country_id: uk.id) }
  let!(:subscription_plan_gbp_m) { FactoryBot.create(:student_subscription_plan_m,
                                                     currency_id: gbp.id, price: 7.50) }
  let!(:subscription_plan_gbp_q) { FactoryBot.create(:student_subscription_plan_q,
                                                     currency_id: gbp.id, price: 22.50) }
  let!(:subscription_plan_gbp_y) { FactoryBot.create(:student_subscription_plan_y,
                                                     currency_id: gbp.id, price: 87.99) }

  let!(:student_user_group ) { FactoryBot.create(:student_user_group ) }
  let!(:valid_trial_student) { FactoryBot.create(:valid_free_trial_student,
                                                 user_group_id: student_user_group.id) }
  let!(:valid_trial_student_access) { FactoryBot.create(:valid_free_trial_student_access,
                                                        user_id: valid_trial_student.id) }
  let!(:valid_subscription_student) { FactoryBot.create(:valid_subscription_student,
                                                        user_group_id: student_user_group.id) }
  let!(:valid_subscription_student_access) { FactoryBot.create(:trial_student_access,
                                                               user_id: valid_subscription_student.id) }

  let!(:valid_subscription) { FactoryBot.create(:valid_subscription, user_id: valid_subscription_student.id,
                                                stripe_customer_id: valid_subscription_student.stripe_customer_id ) }

  let!(:valid_params) { FactoryBot.attributes_for(:subscription) }

  context 'Logged in as a valid_trial_student: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(valid_trial_student)
    end

    describe "GET 'new'" do
      it 'should render upgrade page' do
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

  context 'Logged in as a valid_subscription_student: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(valid_subscription_student)
    end

    describe "GET 'new'" do
      it 'should render upgrade page' do
        get :new
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to(account_url(anchor: :subscriptions))
      end
    end


  end

  end
