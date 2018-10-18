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
                                                     currency_id: gbp.id, price: 7.50, stripe_guid: 'stripe_plan_guid_m') }
  let!(:subscription_plan_gbp_q) { FactoryBot.create(:student_subscription_plan_q,
                                                     currency_id: gbp.id, price: 22.50, stripe_guid: 'stripe_plan_guid_q') }
  let!(:subscription_plan_gbp_y) { FactoryBot.create(:student_subscription_plan_y,
                                                     currency_id: gbp.id, price: 87.99, stripe_guid: 'stripe_plan_guid_y') }

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
                                                subscription_plan_id: subscription_plan_gbp_m.id,
                                                stripe_customer_id: valid_subscription_student.stripe_customer_id ) }
  let!(:default_card) { FactoryBot.create(:subscription_payment_card, user_id: valid_subscription_student.id,
                                          is_default_card: true, stripe_card_guid: 'guid_222',
                                          status: 'card-live' ) }

  let!(:canceled_pending_student) { FactoryBot.create(:valid_subscription_student,
                                                        user_group_id: student_user_group.id) }
  let!(:canceled_pending_student_access) { FactoryBot.create(:valid_subscription_student_access,
                                                               user_id: canceled_pending_student.id) }

  let!(:canceled_pending_subscription) { FactoryBot.create(:canceled_pending_subscription, user_id: canceled_pending_student.id,
                                                           subscription_plan_id: subscription_plan_gbp_m.id,
                                                           stripe_customer_id: canceled_pending_student.stripe_customer_id ) }

  let!(:coupon_2) { FactoryBot.create(:coupon, name: 'Coupon ABC', code: 'coupon_code_abc',
                                      amount_off: 10, percent_off: nil, currency_id: gbp.id,
                                      duration: 'once', max_redemptions: 10, redeem_by: '2019-02-02 16:14:46') }

  let!(:upgrade_params) { FactoryBot.attributes_for(:subscription, subscription_plan_id: subscription_plan_gbp_m.id,
                                                    user_id: valid_trial_student.id,
                                                    stripe_token: 'stripe_token_123',
                                                    terms_and_conditions: 'true') }
  let!(:change_plan_params) { FactoryBot.attributes_for(:subscription, subscription_plan_id: subscription_plan_gbp_q.id,
                                                    user_id: valid_subscription_student.id,
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
        post_request_body = {"customer"=>valid_trial_student.stripe_customer_id, "plan"=>"stripe_plan_guid_m", "source"=>"stripe_token_123", "trial_end"=>"now"}

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
        post_request_body = {"coupon"=>coupon_2.code, "customer"=>valid_trial_student.stripe_customer_id,  "plan"=>"stripe_plan_guid_m",
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

        get_sub_url = "https://api.stripe.com/v1/customers/#{canceled_pending_student.stripe_customer_id}/subscriptions/#{canceled_pending_subscription.stripe_guid}"
        subscription = {      "id": canceled_pending_subscription.stripe_guid, "object": "subscription",
                              "billing": "charge_automatically",
                               "billing_cycle_anchor": 1540455078, "cancel_at_period_end": false,
                               "created": 1539850278, "current_period_end": 1540455078, "current_period_start": 1539850278,
                               "customer": canceled_pending_student.stripe_customer_id}

        stub_subscription_get_request(get_sub_url, subscription)


        post_url = "https://api.stripe.com/v1/subscriptions/#{canceled_pending_subscription.stripe_guid}"
        post_request_body = {"plan"=>subscription_plan_gbp_m.stripe_guid}

        post_response_body = {"id": canceled_pending_subscription.stripe_guid, "object": "subscription", "livemode": false,
                              "cancel_at_period_end": false, "canceled_at": nil,
                              "current_period_end": 1540455078, "plan": {"id": "test-mubaohLn5BuRVQ8rOE4M",
                                                                         "object": "plan", "active": true,
                                                                         "amount": 999, "livemode": false },
                              "status": "active"
        }
        stub_subscription_post_request(post_url, post_request_body, post_response_body)

        put :un_cancel_subscription, id: canceled_pending_subscription.id
        expect(flash[:success]).to eq(I18n.t('controllers.subscriptions.un_cancel.flash.success'))
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to account_url(anchor: 'subscriptions')

        expect(a_request(:get, get_url).with(body: nil)).to have_been_made.once
        expect(a_request(:get, get_sub_url).with(body: nil)).to have_been_made.at_most_times(3)
        expect(a_request(:post, post_url).with(body: post_request_body)).to have_been_made.once
      end

      it 'should redirect to account page as subscription is not canceled-pending' do
        put :un_cancel_subscription, id: valid_subscription.id
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to eq(I18n.t('controllers.application.you_are_not_permitted_to_do_that'))
        expect(response.status).to eq(302)
        redirect_to account_url(anchor: 'subscriptions')
      end

    end

    describe "PUT 'update/1'" do
      it 'should create a new subscription then redirect to account' do
        sources = {"id": "guid_222", "object": "source", "client_secret": "src_client_secret_Do8sRLByihYpru4LuNCGYP8L",
                   "created": 1539850277, "currency": "eur", "flow": "receiver", "livemode": false, "status": "pending"
        }
        subscriptions = {      "id": "sub_Do8snl73Oh0FRL", "object": "subscription", "billing": "charge_automatically",
                               "billing_cycle_anchor": 1540455078, "cancel_at_period_end": false,
                               "created": 1539850278, "current_period_end": 1540455078, "current_period_start": 1539850278,
                               "customer": "cus_5oHUt1ZBHOcfUT"
        }

        get_url = "https://api.stripe.com/v1/customers/#{valid_subscription.stripe_customer_id}"
        get_response_body = {"id": valid_subscription.stripe_customer_id, "object": "customer", "account_balance": 0,
                             "invoice_prefix": "1C44D6D", "livemode": false,"default_source": "src_Do8swBcNDszFmc",
                             "sources": {"object": "list", "data": [sources], "has_more": false, "total_count": 0,
                                         "url": "/v1/customers/cus_Do8skFvJFlWtvy/sources"},
                             "subscriptions": {
                                 "object": "list",
                                 "data": [subscriptions],
                                 "has_more": false,
                                 "total_count": 0,
                                 "url": "/v1/customers/#{valid_subscription.stripe_customer_id}/subscriptions"
                             }
        }
        stub_customer_get_request(get_url, get_response_body)

        get_sub_url = "https://api.stripe.com/v1/customers/#{valid_subscription.stripe_customer_id}/subscriptions/#{valid_subscription.stripe_guid}"
        subscription = {      "id": valid_subscription.stripe_guid, "object": "subscription",
                              "billing": "charge_automatically",
                              "billing_cycle_anchor": 1540455078, "cancel_at_period_end": false,
                              "created": 1539850278, "current_period_end": 1540455078, "current_period_start": 1539850278,
                              "customer": valid_subscription.stripe_customer_id}

        stub_subscription_get_request(get_sub_url, subscription)




        post_url = "https://api.stripe.com/v1/subscriptions/#{valid_subscription.stripe_guid}"
        post_request_body = {"plan"=>subscription_plan_gbp_q.stripe_guid, "prorate"=>"true", "trial_end"=>"now"}

        post_response_body = {"id": "sub_guid_11", "object": "subscription", "livemode": false,
                              "cancel_at_period_end": false, "canceled_at": nil,
                              "current_period_end": 1540455078, "plan": {"id": "test-mubaohLn5BuRVQ8rOE4M",
                                                                         "object": "plan", "active": true,
                                                                         "amount": 999, "livemode": false },
                              "status": "active"
        }
        stub_subscription_post_request(post_url, post_request_body, post_response_body)

        put :update, id: valid_subscription.id, subscription: change_plan_params
        expect(flash[:success]).to eq(I18n.t('controllers.subscriptions.update.flash.success'))
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to account_url(anchor: 'subscriptions')

        expect(a_request(:get, get_url).with(body: nil)).to have_been_made.at_most_times(2)
        expect(a_request(:get, get_sub_url).with(body: nil)).to have_been_made.at_most_times(2)
        expect(a_request(:post, post_url).with(body: post_request_body)).to have_been_made.once

      end

      it 'should redirect to account page as no default card' do
        put :update, id: canceled_pending_subscription.id, subscription: change_plan_params
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to eq(I18n.t('controllers.subscriptions.update.flash.invalid_card'))
        expect(response.status).to eq(302)
        expect(response).to redirect_to account_url(anchor: 'payment-details')
      end

    end

    describe "DELETE 'destroy'" do
      it 'should redirect to account page updating to canceled-pending' do
        sources = {"id": "guid_222", "object": "source", "client_secret": "src_client_secret_Do8sRLByihYpru4LuNCGYP8L",
                   "created": 1539850277, "currency": "eur", "flow": "receiver", "livemode": false, "status": "pending"
        }
        subscriptions = {      "id": "sub_Do8snl73Oh0FRL", "object": "subscription", "billing": "charge_automatically",
                               "billing_cycle_anchor": 1540455078, "cancel_at_period_end": false,
                               "created": 1539850278, "current_period_end": 1540455078, "current_period_start": 1539850278,
                               "customer": "cus_5oHUt1ZBHOcfUT"
        }

        get_url = "https://api.stripe.com/v1/customers/#{valid_subscription.stripe_customer_id}"
        get_response_body = {"id": valid_subscription.stripe_customer_id, "object": "customer", "account_balance": 0,
                             "invoice_prefix": "1C44D6D", "livemode": false,"default_source": "src_Do8swBcNDszFmc",
                             "sources": {"object": "list", "data": [sources], "has_more": false, "total_count": 0,
                                         "url": "/v1/customers/cus_Do8skFvJFlWtvy/sources"},
                             "subscriptions": {
                                 "object": "list",
                                 "data": [subscriptions],
                                 "has_more": false,
                                 "total_count": 0,
                                 "url": "/v1/customers/#{valid_subscription.stripe_customer_id}/subscriptions"
                             }
        }
        stub_customer_get_request(get_url, get_response_body)

        get_sub_url = "https://api.stripe.com/v1/customers/#{valid_subscription.stripe_customer_id}/subscriptions/#{valid_subscription.stripe_guid}"
        subscription = {      "id": valid_subscription.stripe_guid, "object": "subscription",
                              "billing": "charge_automatically",
                              "billing_cycle_anchor": 1540455078, "cancel_at_period_end": false,
                              "created": 1539850278, "current_period_end": 1540455078, "current_period_start": 1539850278,
                              "customer": valid_subscription.stripe_customer_id}

        stub_subscription_get_request(get_sub_url, subscription)


        url = "https://api.stripe.com/v1/subscriptions/#{valid_subscription.stripe_guid}?at_period_end=true"
        subscription = {      "id": valid_subscription.stripe_guid, "object": "subscription",
                              "billing": "charge_automatically", "status": "active",
                              "billing_cycle_anchor": 1540455078, "cancel_at_period_end": true,
                              "created": 1539850278, "current_period_end": 1540455078, "current_period_start": 1539850278,
                              "customer": valid_subscription.stripe_customer_id}

        stub_subscription_delete_request(url, subscription)

        delete :destroy, id: valid_subscription.id
        valid_subscription.reload
        expect(valid_subscription.current_status).to eq('canceled-pending')
        expect(flash[:success]).to eq(I18n.t('controllers.subscriptions.destroy.flash.success'))
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to account_url(anchor: 'subscriptions')

      end
    end

  end


end
