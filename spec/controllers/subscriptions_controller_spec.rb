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
require 'support/stripe_web_mock_helpers'

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

  let!(:canceled_pending_student) { FactoryBot.create(:valid_subscription_student,
                                                        user_group_id: student_user_group.id) }
  let!(:canceled_pending_student_access) { FactoryBot.create(:valid_subscription_student_access,
                                                               user_id: canceled_pending_student.id) }

  let!(:canceled_pending_subscription) { FactoryBot.create(:canceled_pending_subscription, user_id: canceled_pending_student.id,
                                                stripe_customer_id: canceled_pending_student.stripe_customer_id ) }

  let!(:coupon_2) { FactoryBot.create(:coupon, name: 'Coupon ABC', code: 'coupon_code_abc',
                                      amount_off: 10, percent_off: nil, currency_id: gbp.id,
                                      duration: 'once', max_redemptions: 10, redeem_by: '2019-02-02 16:14:46') }

  let!(:upgrade_params) { FactoryBot.attributes_for(:subscription, subscription_plan_id: subscription_plan_gbp_m.id,
                                                    user_id: valid_trial_student.id,
                                                    stripe_token: 'stripe_token_123',
                                                    terms_and_conditions: 'true') }
  let!(:invalid_upgrade_params_1) { FactoryBot.attributes_for(:subscription, subscription_plan_id: subscription_plan_gbp_m.id,
                                                    stripe_token: 'stripe_token_123',
                                                    terms_and_conditions: 'false') }
  let!(:invalid_upgrade_params_2) { FactoryBot.attributes_for(:subscription, subscription_plan_id: subscription_plan_gbp_m.id,
                                                    stripe_token: nil,
                                                    terms_and_conditions: 'true') }

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
      it 'should respond okay with correct params' do
        sources = {"id": "src_Do8swBcNDszFmc", "object": "source", "client_secret": "src_client_secret_Do8sRLByihYpru4LuNCGYP8L",
                   "created": 1539850277, "currency": "eur", "flow": "receiver", "livemode": false, "status": "pending"
        }
        get_url = "https://api.stripe.com/v1/customers/#{valid_trial_student.stripe_customer_id}"
        get_response_body = {"id": valid_trial_student.stripe_customer_id, "object": "customer", "account_balance": 0,
                         "invoice_prefix": "1C44D6D", "livemode": false,"default_source": "src_Do8swBcNDszFmc",
                             "sources": {"object": "list", "data": [sources], "has_more": false, "total_count": 0,
                                         "url": "/v1/customers/cus_Do8skFvJFlWtvy/sources"}
        }
        stub_customer_get_request(get_url, get_response_body)

        post_url = 'https://api.stripe.com/v1/subscriptions'
        post_request_body = {"customer"=>valid_trial_student.stripe_customer_id, "source"=>"stripe_token_123", "trial_end"=>"now"}

        post_response_body = {"id": "sub_Do8snl73Oh0FRL", "object": "subscription", "livemode": false,
                              "current_period_end": 1540455078, "plan": {"id": "test-mubaohLn5BuRVQ8rOE4M",
                                                                         "object": "plan", "active": true,
                                                                         "amount": 999, "livemode": false },
                              "status": "active"
        }
        stub_subscription_post_request(post_url, post_request_body, post_response_body)

        post :create, subscription: upgrade_params, user_id: valid_trial_student.id
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to personal_upgrade_complete_url

        expect(a_request(:get, get_url).with(body: nil)).to have_been_made.at_most_times(3)
        expect(a_request(:post, post_url).with(body: post_request_body)).to have_been_made.once
      end

      it 'should respond with Error Your request was declined. T&Cs false' do
        post :create, subscription: invalid_upgrade_params_1, user_id: valid_trial_student.id
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to eq('Sorry Something went wrong! You must agree to our Terms & Conditions.')
        expect(response.status).to eq(302)
        expect(response).to redirect_to(new_subscription_url)
        expect(a_request(:any, 'https://api.stripe.com/v1/')).not_to have_been_made
      end

      it 'should respond with Error Your request was declined. With Bad params' do
        post :create, subscription: invalid_upgrade_params_2, user_id: valid_trial_student.id
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to eq('Sorry! The data entered is not valid. Please contact us for assistance.')
        expect(response.status).to eq(302)
        expect(response).to redirect_to(new_subscription_url)
        expect(a_request(:any, 'https://api.stripe.com/v1/')).not_to have_been_made
      end

      it 'should respond okay with correct params without coupon' do
        sources = {"id": "src_Do8swBcNDszFmc", "object": "source", "client_secret": "src_client_secret_Do8sRLByihYpru4LuNCGYP8L",
                   "created": 1539850277, "currency": "eur", "flow": "receiver", "livemode": false, "status": "pending"
        }
        get_url = "https://api.stripe.com/v1/customers/#{valid_trial_student.stripe_customer_id}"
        get_response_body = {"id": valid_trial_student.stripe_customer_id, "object": "customer", "account_balance": 0,
                             "invoice_prefix": "1C44D6D", "livemode": false,"default_source": "src_Do8swBcNDszFmc",
                             "sources": {"object": "list", "data": [sources], "has_more": false, "total_count": 0,
                                         "url": "/v1/customers/cus_Do8skFvJFlWtvy/sources"}
        }
        stub_customer_get_request(get_url, get_response_body)

        post_url = 'https://api.stripe.com/v1/subscriptions'
        post_request_body = {"coupon"=>coupon_2.code, "customer"=>valid_trial_student.stripe_customer_id,
                             "source"=>"stripe_token_123", "trial_end"=>"now"}

        post_response_body = {"id": "sub_Do8snl73Oh0FRL", "object": "subscription", "livemode": false,
                              "current_period_end": 1540455078, "plan": {"id": "test-mubaohLn5BuRVQ8rOE4M",
                                                                         "object": "plan", "active": true,
                                                                         "amount": 999, "livemode": false },
                              "status": "active"
        }
        stub_subscription_post_request(post_url, post_request_body, post_response_body)



        post :create, subscription: upgrade_params, user_id: valid_trial_student.id, hidden_coupon_code: coupon_2.code
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to personal_upgrade_complete_url
        expect(a_request(:get, get_url).with(body: nil)).to have_been_made.at_most_times(3)
        expect(a_request(:post, post_url).with(body: post_request_body)).to have_been_made.once

      end

      it 'should respond with Error coupon is invalid' do

        sources = {"id": "src_Do8swBcNDszFmc", "object": "source", "client_secret": "src_client_secret_Do8sRLByihYpru4LuNCGYP8L",
                   "created": 1539850277, "currency": "eur", "flow": "receiver", "livemode": false, "status": "pending"
        }
        get_url = "https://api.stripe.com/v1/customers/#{valid_trial_student.stripe_customer_id}"
        get_response_body = {"id": valid_trial_student.stripe_customer_id, "object": "customer", "account_balance": 0,
                             "invoice_prefix": "1C44D6D", "livemode": false,"default_source": "src_Do8swBcNDszFmc",
                             "sources": {"object": "list", "data": [sources], "has_more": false, "total_count": 0,
                                         "url": "/v1/customers/cus_Do8skFvJFlWtvy/sources"}
        }
        stub_customer_get_request(get_url, get_response_body)


        post :create, subscription: upgrade_params, user_id: valid_trial_student.id, hidden_coupon_code: 'bad_coupon_001'
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to eq('Sorry! That is not a valid coupon code.')
        expect(response.status).to eq(302)
        expect(response).to redirect_to(new_subscription_url(coupon: true))

        expect(a_request(:any, 'https://api.stripe.com/v1/')).not_to have_been_made

      end

    end

    describe "GET 'personal_upgrade_complete'" do
      it 'should render upgrade complete page' do
        get :personal_upgrade_complete
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:personal_upgrade_complete)
      end
    end

    describe "Get 'change_plan'" do
      it 'should redirect to account page as no existing subscription' do
        get :change_plan
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to new_subscription_url
      end
    end

    describe "Post 'un_cancel_subscription'" do
      it 'should successfully change subscription to active' do

        sources = {"id": "src_Do8swBcNDszFmc", "object": "source", "client_secret": "src_client_secret_Do8sRLByihYpru4LuNCGYP8L",
                   "created": 1539850277, "currency": "eur", "flow": "receiver", "livemode": false, "status": "pending"
        }
        subscriptions = {      "id": "sub_Do8snl73Oh0FRL", "object": "subscription", "billing": "charge_automatically",
                               "billing_cycle_anchor": 1540455078, "cancel_at_period_end": false,
                               "created": 1539850278, "current_period_end": 1540455078, "current_period_start": 1539850278,
                               "customer": "cus_5oHUt1ZBHOcfUT"
        }

        get_url = "https://api.stripe.com/v1/customers/#{canceled_pending_student.stripe_customer_id}"
        get_response_body = {"id": canceled_pending_student.stripe_customer_id, "object": "customer", "account_balance": 0,
                             "invoice_prefix": "1C44D6D", "livemode": false,"default_source": "src_Do8swBcNDszFmc",
                             "sources": {"object": "list", "data": [sources], "has_more": false, "total_count": 0,
                                         "url": "/v1/customers/cus_Do8skFvJFlWtvy/sources"},
                             "subscriptions": {
                                 "object": "list",
                                 "data": [subscriptions],
                                 "has_more": false,
                                 "total_count": 0,
                                 "url": "/v1/customers/#{canceled_pending_student.stripe_customer_id}/subscriptions"
                             }
        }
        stub_customer_get_request(get_url, get_response_body)


        put :un_cancel_subscription, id: canceled_pending_subscription.id
        expect(flash[:success]).to eq(I18n.t('controllers.subscriptions.un_cancel.flash.success'))
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to new_subscription_url
      end

      it 'should redirect to account page as subscription is not canceled-pending' do
        put :un_cancel_subscription, id: canceled_pending_subscription.id
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to eq(I18n.t('controllers.application.you_are_not_permitted_to_do_that'))
        expect(response.status).to eq(302)
        expect(response).to redirect_to account_url(anchor: 'subscriptions')
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

      it 'should redirect to account page as no valid card' do
        post :un_cancel_subscription
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to eq(I18n.t('controllers.subscriptions.update.flash.invalid_card'))
        expect(response.status).to eq(302)
        expect(response).to redirect_to new_subscription_url
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
