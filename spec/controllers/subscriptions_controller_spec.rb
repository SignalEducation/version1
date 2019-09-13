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
#  cancelled_at             :datetime
#  cancellation_reason      :string
#  cancellation_note        :text
#

require 'rails_helper'

describe SubscriptionsController, type: :controller do
  render_views
  before :each do
    allow_any_instance_of(SubscriptionPlanService).to receive(:queue_async)
  end

  let!(:exam_body_1) { FactoryBot.create(:exam_body) }
  let!(:gbp) { create(:gbp) }
  let!(:uk) { create(:uk, currency: gbp) }
  let!(:uk_vat_code) { create(:vat_code, country: uk) }
  let!(:subscription_plan_gbp_m) {
    create(
        :student_subscription_plan_m,
        currency: gbp, price: 7.50, stripe_guid: 'stripe_plan_guid_m',
        payment_frequency_in_months: 3,
        exam_body: exam_body_1
    )
  }
  let!(:subscription_plan_gbp_q) {
    create(
        :student_subscription_plan_q,
        currency: gbp, price: 22.50, stripe_guid: 'stripe_plan_guid_q',
        payment_frequency_in_months: 3,
        exam_body: exam_body_1
    )
  }
  let!(:subscription_plan_gbp_y) {
    create(
        :student_subscription_plan_y,
        currency: gbp, price: 87.99, stripe_guid: 'stripe_plan_guid_y',
        payment_frequency_in_months: 12,
        exam_body: exam_body_1
    )
  }

  let!(:student_user_group ) { create(:student_user_group ) }
  let!(:basic_student) { create(:basic_student, user_group: student_user_group, preferred_exam_body_id: exam_body_1.id, country: uk) }
  let!(:valid_subscription_student) { create(:basic_student, user_group: student_user_group, preferred_exam_body_id: exam_body_1.id) }
  let!(:canceled_pending_student) { create(:basic_student, user_group: student_user_group, preferred_exam_body_id: exam_body_1.id) }

  let!(:valid_subscription) { create(:valid_subscription, user: valid_subscription_student,
                                     stripe_guid: 'sub_123',
                                     subscription_plan: subscription_plan_gbp_m,
                                     stripe_customer_id: valid_subscription_student.stripe_customer_id ) }
  let!(:default_card) { create(:subscription_payment_card, user: valid_subscription_student,
                               is_default_card: true, stripe_card_guid: 'guid_222',
                               status: 'card-live' ) }

  let!(:canceled_pending_subscription) {
    create(
        :canceled_pending_subscription,
        state: 'pending_cancellation',
        user: canceled_pending_student,
        subscription_plan: subscription_plan_gbp_m,
        stripe_guid: 'sub_abc123',
        stripe_customer_id: canceled_pending_student.stripe_customer_id
    )
  }


  let!(:upgrade_params) {
    attributes_for(
        :subscription,
        user_id: basic_student.id,
        stripe_token: 'stripe_token_123',
        subscription_plan_id: subscription_plan_gbp_m.id,
        terms_and_conditions: 'true'
    )
  }

  let!(:change_plan_params) { attributes_for(:subscription, subscription_plan: subscription_plan_gbp_q,
                                             user: valid_subscription_student,
                                             stripe_token: 'stripe_token_123',
                                             terms_and_conditions: 'true') }
  let!(:invalid_upgrade_params_1) { attributes_for(:subscription, subscription_plan: subscription_plan_gbp_m,
                                                   stripe_token: 'stripe_token_123',
                                                   terms_and_conditions: 'false') }
  let!(:invalid_upgrade_params_2) { attributes_for(:subscription, subscription_plan: subscription_plan_gbp_m,
                                                   stripe_token: nil,
                                                   terms_and_conditions: 'true') }

  let!(:valid_params) { attributes_for(:subscription) }

  context 'Logged in as a basic_student: ' do
    let(:data) { { client_secret: Faker::Alphanumeric.alphanumeric, status: :ok } }

    before(:each) do
      valid_subscription.client_secret = data[:client_secret]
      activate_authlogic
      UserSession.create!(basic_student)
      valid_subscription.start
      allow_any_instance_of(StripeSubscriptionService).to(
        receive(:create_and_return_subscription).
          and_return([valid_subscription, data])
      )
    end

    describe "GET 'new'" do
      it 'should render upgrade page' do
        get :new, params: { exam_body_id: exam_body_1.id }
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:new)
      end
    end

    describe "POST 'create'" do
      let(:client_secret) { data[:client_secret] }

      it 'should respond okay with correct params' do
        sources = {"id": "src_Do8swBcNDszFmc", "object": "source", "client_secret": "src_client_secret_Do8sRLByihYpru4LuNCGYP8L",
                   "created": 1539850277, "currency": "eur", "flow": "receiver", "livemode": false, "status": "pending"
        }
        get_url = "https://api.stripe.com/v1/customers/#{basic_student.stripe_customer_id}"
        get_response_body = {"id": basic_student.stripe_customer_id, "object": "customer", "account_balance": 0,
                             "invoice_prefix": "1C44D6D", "livemode": false,"default_source": "src_Do8swBcNDszFmc",
                             "sources": {"object": "list", "data": [sources], "has_more": false, "total_count": 0,
                                         "url": "/v1/customers/cus_Do8skFvJFlWtvy/sources"}
        }
        stub_customer_get_request(get_url, get_response_body)

        update_url = "https://api.stripe.com/v1/customers/#{basic_student.stripe_customer_id}"
        update_request_body = {"source"=>"stripe_token_123"}
        update_response_body = {'id': basic_student.stripe_customer_id, 'object': 'customer' }.to_json

        stub_customer_update_request(update_url, update_request_body, update_response_body)

        post_url = 'https://api.stripe.com/v1/subscriptions'
        post_request_body = { "customer"=>basic_student.stripe_customer_id, "expand"=>["latest_invoice.payment_intent"], "items": [{"plan"=>"stripe_plan_guid_m", "quantity"=>"1"}], "trial_end"=>"now"}

        post_response_body = {"id": "sub_Do8snl73Oh0FRL", "object": "subscription", "livemode": false,
                              "current_period_end": 1540455078, "plan": {"id": "test-mubaohLn5BuRVQ8rOE4M",
                                                                         "object": "plan", "active": true,
                                                                         "amount": 999, "livemode": false },
                              "status": 'active',
                              "latest_invoice": { "payment_intent": { "client_secret": client_secret } }
        }
        stub_subscription_post_request(post_url, post_request_body, post_response_body)

        post :create, format: 'json', params: { subscription: upgrade_params.merge(subscription_plan_id: subscription_plan_gbp_m.id, user_id: basic_student.id),
                                "payment-options": 'stripe' }

        body = JSON.parse(response.body)

        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(body['status']).to eq('active')

        expect(body['client_secret']).to eq(client_secret)
        expect(response.status).to eq(200)
        expect(a_request(:get, get_url).with(body: nil)).to have_been_made.at_most_times(3)
      end

      it 'should respond with Error Your request was declined. T&Cs false' do
        post :create, format: 'json', params: { subscription: invalid_upgrade_params_1, user_id: basic_student.id, "payment-options": 'stripe' }
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to eq('Sorry! The data entered is not valid. Please contact us for assistance.')
        expect(response.status).to eq(302)
        expect(response).to redirect_to(new_subscription_url)
        expect(a_request(:any, 'https://api.stripe.com/v1/')).not_to have_been_made
      end

      it 'should respond with Error Your request was declined. With Bad params' do
        post :create, format: 'json', params: { subscription: invalid_upgrade_params_2, user_id: basic_student.id, "payment-options": 'stripe'  }
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to eq('Sorry! The data entered is not valid. Please contact us for assistance.')
        expect(response.status).to eq(302)
        expect(response).to redirect_to(new_subscription_url)
        expect(a_request(:any, 'https://api.stripe.com/v1/')).not_to have_been_made
      end

      it 'should respond okay with correct params ' do
        sources = {"id": "src_Do8swBcNDszFmc", "object": "source", "client_secret": "src_client_secret_Do8sRLByihYpru4LuNCGYP8L",
                   "created": 1539850277, "currency": "eur", "flow": "receiver", "livemode": false, "status": "pending"
        }
        get_url = "https://api.stripe.com/v1/customers/#{basic_student.stripe_customer_id}"
        get_response_body = {"id": basic_student.stripe_customer_id, "object": "customer", "account_balance": 0,
                             "invoice_prefix": "1C44D6D", "livemode": false,"default_source": "src_Do8swBcNDszFmc",
                             "sources": {"object": "list", "data": [sources], "has_more": false, "total_count": 0,
                                         "url": "/v1/customers/cus_Do8skFvJFlWtvy/sources"}
        }
        stub_customer_get_request(get_url, get_response_body)

        update_url = "https://api.stripe.com/v1/customers/#{basic_student.stripe_customer_id}"
        update_request_body = {"source"=>"stripe_token_123"}
        update_response_body = {'id': basic_student.stripe_customer_id, 'object': 'customer' }.to_json

        stub_customer_update_request(update_url, update_request_body, update_response_body)

        post_url = 'https://api.stripe.com/v1/subscriptions'
        post_request_body = {"customer"=>basic_student.stripe_customer_id, "expand"=>["latest_invoice.payment_intent"],
                             items: [{"plan"=>"stripe_plan_guid_m", quantity: 1}], "trial_end"=>"now"}

        post_response_body = {"id": "sub_Do8snl73Oh0FRL", "object": "subscription", "livemode": false,
                              "current_period_end": 1540455078, "plan": {"id": "test-mubaohLn5BuRVQ8rOE4M",
                                                                         "object": "plan", "active": true,
                                                                         "amount": 999, "livemode": false },
                              "status": "active",
                              "latest_invoice": { "payment_intent": { "client_secret": client_secret } }
        }
        stub_subscription_post_request(post_url, post_request_body, post_response_body)

        post :create, format: 'json', params: { subscription: upgrade_params, "payment-options": 'stripe' }
        body = JSON.parse(response.body)
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(a_request(:get, get_url).with(body: nil)).to have_been_made.at_most_times(3)
        expect(body.keys).to include('subscription_id', 'status', 'client_secret')
        expect(body['status']).to eq('active')
      end
    end

    describe "Post 'un_cancel'" do
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
        subscription = { "id": canceled_pending_subscription.stripe_guid, "object": "subscription",
                         "billing": "charge_automatically",
                         "billing_cycle_anchor": 1540455078, "cancel_at_period_end": false,
                         "created": 1539850278, "current_period_end": 1540455078, "current_period_start": 1539850278,
                         "customer": canceled_pending_student.stripe_customer_id }

        stub_subscription_get_request(get_sub_url, subscription)


        post_url = "https://api.stripe.com/v1/subscriptions/#{canceled_pending_subscription.stripe_guid}"
        post_request_body = {"cancel_at_period_end"=>"false"}

        post_response_body = {"id": canceled_pending_subscription.stripe_guid, "object": "subscription", "livemode": false,
                              "cancel_at_period_end": false, "canceled_at": nil,
                              "current_period_end": 1540455078, "plan": {"id": "test-mubaohLn5BuRVQ8rOE4M",
                                                                         "object": "plan", "active": true,
                                                                         "amount": 999, "livemode": false },
                              "status": "active"
        }
        stub_subscription_post_request(post_url, post_request_body, post_response_body)

        put :un_cancel, params: { id: canceled_pending_subscription.id }
        expect(flash[:success]).to eq(I18n.t('controllers.subscriptions.un_cancel.flash.success'))
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to account_url(anchor: 'account-info')

        expect(a_request(:get, get_url).with(body: nil)).to have_been_made.once
        expect(a_request(:get, get_sub_url).with(body: nil)).to have_been_made.at_most_times(3)
        expect(a_request(:post, post_url).with(body: post_request_body)).to have_been_made.once
      end

      it 'should redirect to account page as subscription is not canceled-pending' do
        put :un_cancel, params: { id: valid_subscription.id }
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to eq(I18n.t('controllers.application.you_are_not_permitted_to_do_that'))
        expect(response.status).to eq(302)
        redirect_to account_url(anchor: 'account-info')
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


        url = "https://api.stripe.com/v1/subscriptions/#{valid_subscription.stripe_guid}"
        request_body = {"cancel_at_period_end"=>"true"}
        response_body = {
          "status": "active", "cancel_at_period_end": true
        }

        stub_subscription_post_request(url, request_body, response_body)

        delete :destroy, params: { id: valid_subscription.id }
        valid_subscription.reload
        expect(valid_subscription.stripe_status).to eq('canceled-pending')
        expect(flash[:success]).to eq(I18n.t('controllers.subscriptions.destroy.flash.success'))
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(302)
        expect(response).to redirect_to account_url(anchor: 'account-info')
      end
    end
  end

  context 'Logged in as a valid_subscription_student: ' do
    before(:each) do
      activate_authlogic
      UserSession.create!(valid_subscription_student)
      valid_subscription.start
    end

    describe "GET 'personal_upgrade_complete'" do
      it 'should render upgrade complete page' do
        get :personal_upgrade_complete, params: { completion_guid: valid_subscription.completion_guid }
        expect(flash[:success]).to be_nil
        expect(flash[:error]).to be_nil
        expect(response.status).to eq(200)
        expect(response).to render_template(:personal_upgrade_complete)
        valid_subscription.reload
        expect(valid_subscription.completion_guid).to eq(nil)
      end
    end
  end
end
