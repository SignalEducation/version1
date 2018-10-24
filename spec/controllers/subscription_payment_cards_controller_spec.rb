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
require 'support/stripe_web_mock_helpers'

RSpec.describe SubscriptionPaymentCardsController, type: :controller do

  let(:user_management_user_group) { FactoryBot.create(:user_management_user_group) }
  let!(:student_user_group ) { FactoryBot.create(:student_user_group ) }
  let(:user_management_user) { FactoryBot.create(:user_management_user, user_group_id: user_management_user_group.id) }
  let!(:user_management_student_access) { FactoryBot.create(:complimentary_student_access, user_id: user_management_user.id) }
  let!(:student_user) { FactoryBot.create(:student_user, user_group_id: student_user_group.id) }
  let!(:student_access) { FactoryBot.create(:valid_free_trial_student_access, user_id: student_user.id) }

  let!(:create_params) { {stripe_token: 'tk_0000000', user_id: student_user.id} }



  context 'Logged in as user_management_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(user_management_user)
    end

    describe "POST 'create'" do
      xit 'should be OK with redirect' do
        sources = {"id": "src_Do8swBcNDszFmc", "object": "source", "client_secret": "src_client_secret_Do8sRLByihYpru4LuNCGYP8L",
                   "created": 1539850277, "currency": "eur", "flow": "receiver", "livemode": false, "status": "pending"
        }
        get_response_body = {"id": student_user.stripe_customer_id, "object": "customer", "account_balance": 0,
                             "invoice_prefix": "1C44D6D", "livemode": false,"default_source": "src_Do8swBcNDszFmc",
                             "sources": {"object": "list", "data": [sources], "has_more": false, "total_count": 0,
                                         "url": "/v1/customers/#{student_user.stripe_customer_id}/sources"}
        }

        get_url = "https://api.stripe.com/v1/customers/#{student_user.stripe_customer_id}"

        stub_customer_get_request(get_url, get_response_body)

        post_url = "https://api.stripe.com/v1/customers/#{student_user.stripe_customer_id}/sources"
        request_body = {"source"=>"tk_0000000"}
        post_response_body = {"id": "src_Do8swBcNDszFmc", "object": "source", "client_secret": "src_client_secret_Do8sRLByihYpru4LuNCGYP8L",
                              "created": 1539850277, "currency": "eur", "flow": "receiver", "livemode": false, "status": "pending"}

        stub_post_cards_request(post_url, request_body, post_response_body)

        post :create, subscription_payment_card: create_params
        expect(flash[:error]).to eq(nil)
        expect(flash[:success]).to eq(I18n.t('controllers.subscription_payment_cards.create.flash.success'))
        expect(response.status).to eq(302)
        expect(response).to redirect_to(account_url(anchor: 'payment-details'))
      end

      xit 'should report ERROR as token is invalid' do
        post :create, subscription_payment_card: {stripe_token: stripe_bad_token, user_id: student_user_2.id, make_default_card: true}
        expect(flash[:error]).to eq(I18n.t('controllers.subscription_payment_cards.create.flash.error'))
        expect(flash[:success]).to eq(nil)
        expect(response.status).to eq(302)
        expect(response).to redirect_to(account_url(anchor: 'payment-details'))
      end
    end

    describe "PUT 'update'" do
      xit 'should be OK with redirect' do
        put :update, id: card_1.id
        expect(flash[:error]).to eq(nil)
        expect(flash[:success]).to eq(I18n.t('controllers.subscription_payment_cards.update.flash.success'))
        expect(response.status).to eq(302)
        expect(response).to redirect_to(account_url(anchor: 'payment-details'))
      end
    end

  end

end
