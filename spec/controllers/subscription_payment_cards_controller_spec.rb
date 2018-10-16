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

RSpec.describe SubscriptionPaymentCardsController, type: :controller do

  let(:user_management_user_group) { FactoryBot.create(:user_management_user_group) }
  let!(:student_user_group ) { FactoryBot.create(:student_user_group ) }
  let(:user_management_user) { FactoryBot.create(:user_management_user, user_group_id: user_management_user_group.id) }
  let!(:user_management_student_access) { FactoryBot.create(:complimentary_student_access, user_id: user_management_user.id) }
  let!(:student_user) { FactoryBot.create(:student_user, user_group_id: student_user_group.id) }
  let!(:student_access) { FactoryBot.create(:valid_free_trial_student_access, user_id: student_user.id) }

  before { StripeMock.start }
  after { StripeMock.stop }

  let(:stripe_helper) { StripeMock.create_test_helper }
  let(:card_params) { { last4: '4242', exp_mth: 12, exp_year: 2019 } }
  let(:bad_card_params) { { last4: '4241', exp_mth: 12, exp_year: 2012 } }
  let(:stripe_card_token) { stripe_helper.generate_card_token(card_params) }
  let(:stripe_bad_token) { StripeMock.prepare_card_error(:incorrect_number) }

  let(:student_user_2) { FactoryBot.create(:student_user)}
  let!(:stripe_customer_1) { customer = Stripe::Customer.create({
                  email: student_user.email,
                  card: stripe_helper.generate_card_token})
                  student_user.stripe_customer_id = customer.id
                  student_user.save!
                  customer
  }
  let!(:stripe_customer_2) { customer = Stripe::Customer.create({
                  email: student_user_2.email,
                  card: stripe_helper.generate_card_token})
  student_user_2.stripe_customer_id = customer.id
  student_user_2.save!
                  customer
  }

  let(:card_1) { FactoryBot.create(:subscription_payment_card,
                  stripe_token: stripe_helper.generate_card_token(card_params),
                  user_id: student_user.id,
                  customer_guid: student_user.stripe_customer_id) }
  let(:card_2) { FactoryBot.create(:subscription_payment_card,
                  stripe_token: stripe_helper.generate_card_token(card_params),
                  user_id: student_user_2.id,
                  customer_guid: student_user_2.stripe_customer_id) }
  let!(:create_params) { {stripe_token: stripe_card_token, make_default_card: true} }
                  # needs a user_id too


  #TODO - Review this controller does it need stripe_mock?
  context 'Logged in as user_management_user: ' do

    before(:each) do
      activate_authlogic
      UserSession.create!(user_management_user)
    end

    describe "POST 'create'" do
      xit 'should be OK with redirect' do
        post :create, subscription_payment_card: create_params.merge(user_id: student_user.id)
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
