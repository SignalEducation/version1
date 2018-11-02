require 'rails_helper'
require 'support/stripe_web_mock_helpers'

RSpec.describe SubscriptionManagementController, :type => :controller do

  let!(:gbp) { FactoryBot.create(:gbp) }
  let!(:uk) { FactoryBot.create(:uk, currency_id: gbp.id) }
  let!(:subscription_plan_gbp_m) { FactoryBot.create(:student_subscription_plan_m,
                                                     currency_id: gbp.id, price: 7.50, stripe_guid: 'stripe_plan_guid_m') }

  let(:user_management_user_group) { FactoryBot.create(:user_management_user_group) }
  let(:user_management_user) { FactoryBot.create(:user_management_user, user_group_id: user_management_user_group.id) }
  let!(:user_management_student_access) { FactoryBot.create(:complimentary_student_access, user_id: user_management_user.id) }
  let!(:student_user_group ) { FactoryBot.create(:student_user_group ) }
  let!(:valid_subscription_student) { FactoryBot.create(:valid_subscription_student, user_group_id: student_user_group.id) }
  let!(:valid_subscription_student_access) { FactoryBot.create(:trial_student_access, user_id: valid_subscription_student.id) }
  let!(:valid_subscription) { FactoryBot.create(:valid_subscription, user_id: valid_subscription_student.id,
                                                subscription_plan_id: subscription_plan_gbp_m.id,
                                                stripe_customer_id: valid_subscription_student.stripe_customer_id ) }
  let!(:invoice) { FactoryBot.create(:invoice, user_id: valid_subscription_student.id,
                                     subscription_id: valid_subscription.id ) }

  let!(:canceled_pending_student) { FactoryBot.create(:valid_subscription_student,
                                                      user_group_id: student_user_group.id) }
  let!(:canceled_pending_student_access) { FactoryBot.create(:valid_subscription_student_access,
                                                             user_id: canceled_pending_student.id) }

  let!(:canceled_pending_subscription) { FactoryBot.create(:canceled_pending_subscription, user_id: canceled_pending_student.id,
                                                           subscription_plan_id: subscription_plan_gbp_m.id,
                                                           stripe_customer_id: canceled_pending_student.stripe_customer_id ) }

  let!(:canceled_student) { FactoryBot.create(:invalid_subscription_student,
                                                      user_group_id: student_user_group.id) }
  let!(:canceled_student_access) { FactoryBot.create(:invalid_subscription_student_access,
                                                             user_id: canceled_student.id) }

  let!(:canceled_subscription) { FactoryBot.create(:canceled_subscription, user_id: canceled_student.id,
                                                           subscription_plan_id: subscription_plan_gbp_m.id,
                                                           stripe_customer_id: canceled_student.stripe_customer_id ) }
  let!(:default_card) { FactoryBot.create(:subscription_payment_card, user_id: canceled_student.id,
                                          is_default_card: true, stripe_card_guid: 'guid_222',
                                          status: 'card-live' ) }
  let!(:charge) { FactoryBot.create(:charge, user_id: valid_subscription_student.id,
                                          subscription_id: valid_subscription.id, invoice_id: invoice.id,
                                          stripe_customer_id: valid_subscription_student.stripe_customer_id, stripe_invoice_id: invoice.id,
                                          subscription_payment_card_id: default_card.id, stripe_guid: 'stripe_guid_001',
                                          failure_code: '123', failure_message: 'failure', stripe_order_id: 1,
                                          amount: 10, status: 'paid') }


  context 'Logged in as a user_management_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(user_management_user)
    end

    describe "GET 'show'" do
      it 'should see valid_subscription' do
        get :show, id: valid_subscription.id
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:show)
      end
    end

    describe "GET 'invoice'" do
      it 'should see valid invoice' do
        get :invoice, subscription_management_id: valid_subscription.id, invoice_id: invoice.id
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:invoice)
      end

    end

    describe "GET 'charge'" do
      it 'should see valid charge' do
        get :charge, subscription_management_id: valid_subscription.id, invoice_id: invoice.id, id: charge.id
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:charge)
      end

    end

    describe "Post 'un_cancel_subscription'" do
      it 'should see valid invoice' do


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


        post :un_cancel_subscription, subscription_management_id: canceled_pending_subscription.id
        expect(flash[:success]).to eq(I18n.t('controllers.subscription_management.un_cancel_subscription.flash.success'))
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to subscription_management_url(canceled_pending_subscription)

        expect(a_request(:get, get_url).with(body: nil)).to have_been_made.once
        expect(a_request(:get, get_sub_url).with(body: nil)).to have_been_made.at_most_times(3)
        expect(a_request(:post, post_url).with(body: post_request_body)).to have_been_made.once

      end

    end

    describe "Post 'cancel'" do
      it 'should see valid invoice' do
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

        put :cancel, subscription_management_id: valid_subscription.id
        valid_subscription.reload
        expect(valid_subscription.current_status).to eq('canceled-pending')
        expect(flash[:success]).to eq(I18n.t('controllers.subscription_management.cancel.flash.success'))
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to subscription_management_url(valid_subscription)
      end

    end

    describe "Post 'immediate_cancel'" do
      it 'should see valid invoice' do
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

        url = "https://api.stripe.com/v1/subscriptions/#{valid_subscription.stripe_guid}?at_period_end=false"
        subscription = {      "id": valid_subscription.stripe_guid, "object": "subscription",
                              "billing": "charge_automatically", "status": "canceled",
                              "billing_cycle_anchor": 1540455078, "cancel_at_period_end": true,
                              "created": 1539850278, "current_period_end": 1540455078, "current_period_start": 1539850278,
                              "customer": valid_subscription.stripe_customer_id}

        stub_subscription_delete_request(url, subscription)

        post :immediate_cancel, subscription_management_id: valid_subscription.id
        expect(flash[:success]).to eq(I18n.t('controllers.subscription_management.immediately_cancel.flash.success'))
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to subscription_management_url(valid_subscription)
      end

    end

    describe "Post 'reactivate_subscription'" do
      it 'should see valid invoice' do

        sources = {"id": "guid_222", "object": "source", "client_secret": "src_client_secret_Do8sRLByihYpru4LuNCGYP8L",
                   "created": 1539850277, "currency": "eur", "flow": "receiver", "livemode": false, "status": "pending"
        }
        subscriptions = {      "id": "sub_Do8snl73Oh0FRL", "object": "subscription", "billing": "charge_automatically",
                               "billing_cycle_anchor": 1540455078, "cancel_at_period_end": false,
                               "created": 1539850278, "current_period_end": 1540455078, "current_period_start": 1539850278,
                               "customer": "cus_5oHUt1ZBHOcfUT"
        }

        get_url = "https://api.stripe.com/v1/customers/#{canceled_subscription.stripe_customer_id}"
        get_response_body = {"id": canceled_subscription.stripe_customer_id, "object": "customer", "account_balance": 0,
                             "invoice_prefix": "1C44D6D", "livemode": false,"default_source": "src_Do8swBcNDszFmc",
                             "sources": {"object": "list", "data": [sources], "has_more": false, "total_count": 0,
                                         "url": "/v1/customers/cus_Do8skFvJFlWtvy/sources"},
                             "subscriptions": {
                                 "object": "list",
                                 "data": [],
                                 "has_more": false,
                                 "total_count": 0,
                                 "url": "/v1/customers/#{canceled_subscription.stripe_customer_id}/subscriptions"
                             }
        }
        stub_customer_get_request(get_url, get_response_body)

        post_url = 'https://api.stripe.com/v1/subscriptions'
        post_request_body = {"customer"=>canceled_subscription.stripe_customer_id, "plan"=>"stripe_plan_guid_m", "trial_end"=>"now"}

        post_response_body = {"id": "sub_Do8snl73Oh0FRL", "object": "subscription", "livemode": false,
                              "current_period_end": 1540455078, "plan": {"id": "test-mubaohLn5BuRVQ8rOE4M",
                                                                         "object": "plan", "active": true,
                                                                         "amount": 999, "livemode": false },
                              "status": "active"
        }
        stub_subscription_post_request(post_url, post_request_body, post_response_body)

        post :reactivate_subscription, subscription_management_id: canceled_subscription.id
        expect(flash[:success]).to eq(I18n.t('controllers.subscription_management.reactivate_canceled.flash.success'))
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to subscription_management_url(canceled_subscription)
      end

    end

  end

end