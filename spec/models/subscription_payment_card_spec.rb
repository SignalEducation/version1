# frozen_string_literal: true

# == Schema Information
#
# Table name: subscription_payment_cards
#
#  id                  :integer          not null, primary key
#  user_id             :integer
#  stripe_card_guid    :string(255)
#  status              :string(255)
#  brand               :string(255)
#  last_4              :string(255)
#  expiry_month        :integer
#  expiry_year         :integer
#  address_line1       :string(255)
#  account_country     :string(255)
#  account_country_id  :integer
#  created_at          :datetime
#  updated_at          :datetime
#  stripe_object_name  :string(255)
#  funding             :string(255)
#  cardholder_name     :string(255)
#  fingerprint         :string(255)
#  cvc_checked         :string(255)
#  address_line1_check :string(255)
#  address_zip_check   :string(255)
#  dynamic_last4       :string(255)
#  customer_guid       :string(255)
#  is_default_card     :boolean          default("false")
#  address_line2       :string(255)
#  address_city        :string(255)
#  address_state       :string(255)
#  address_zip         :string(255)
#  address_country     :string(255)
#
require 'rails_helper'

describe SubscriptionPaymentCard do
  let(:user)                      { create(:user) }
  let(:stripe_user)               { create(:user, stripe_customer_id: Faker::Alphanumeric.alpha(number: 10)) }
  let(:currency)                  { create(:currency) }
  let(:stripe_token)              { Faker::Alphanumeric.alpha(number: 10) }
  let(:subscription_payment_card) { build(:subscription_payment_card, user: user) }
  let(:previous_payment_card)     { build(:subscription_payment_card, user: user, status: 'card-live') }
  let(:payment_card) {
    JSON.parse(file_fixture('stripe/payment_card.json').read).with_indifferent_access
  }

  # Constants
  it { expect(SubscriptionPaymentCard.const_defined?(:STATUSES)).to eq(true) }

  # relationships
  it { should have_many(:charges) }
  it { should belong_to(:user) }
  it { should belong_to(:account_address_country) }

  # validation
  it { should validate_presence_of(:user_id) }

  it { should validate_presence_of(:stripe_card_guid) }
  it { should validate_length_of(:stripe_card_guid).is_at_most(255) }

  it { should validate_inclusion_of(:status).in_array(SubscriptionPaymentCard::STATUSES) }
  it { should validate_length_of(:status).is_at_most(255) }

  it { should validate_presence_of(:brand) }
  it { should validate_length_of(:brand).is_at_most(255) }

  it { should validate_presence_of(:last_4) }
  it { should validate_length_of(:last_4).is_at_most(255) }

  it { should validate_presence_of(:expiry_month) }

  it { should validate_presence_of(:expiry_year) }

  it { should_not validate_presence_of(:account_country_id) }

  it { should validate_length_of(:address_line1).is_at_most(255) }
  it { should validate_length_of(:account_country).is_at_most(255) }
  it { should validate_length_of(:stripe_object_name).is_at_most(255) }
  it { should validate_length_of(:funding).is_at_most(255) }
  it { should validate_length_of(:cardholder_name).is_at_most(255) }
  it { should validate_length_of(:fingerprint).is_at_most(255) }
  it { should validate_length_of(:cvc_checked).is_at_most(255) }
  it { should validate_length_of(:address_line1_check).is_at_most(255) }
  it { should validate_length_of(:address_zip_check).is_at_most(255) }
  it { should validate_length_of(:dynamic_last4).is_at_most(255) }
  it { should validate_length_of(:customer_guid).is_at_most(255) }
  it { should validate_length_of(:address_line2).is_at_most(255) }
  it { should validate_length_of(:address_city).is_at_most(255) }
  it { should validate_length_of(:address_state).is_at_most(255) }
  it { should validate_length_of(:address_zip).is_at_most(255) }
  it { should validate_length_of(:address_country).is_at_most(255) }

  # callbacks
  it { should callback(:create_on_stripe_using_token).before(:validation).on(:create).if(:stripe_token) }
  it { should callback(:update_stripe_and_other_cards).after(:create) }
  it { should callback(:delete_existing_default_cards).after(:create) }
  it { should callback(:check_dependencies).before(:destroy) }
  it { should callback(:remove_card_from_stripe).before(:destroy) }

  # scopes
  it { expect(SubscriptionPaymentCard).to respond_to(:all_in_order) }
  it { expect(SubscriptionPaymentCard).to respond_to(:all_default_cards) }

  # class methods
  it { expect(SubscriptionPaymentCard).to respond_to(:build_from_stripe_data) }
  it { expect(SubscriptionPaymentCard).to respond_to(:create_from_stripe_array) }

  # instance methods
  it { should respond_to(:create_on_stripe_using_token) }
  it { should respond_to(:destroyable?) }
  it { should respond_to(:status) }
  it { should respond_to(:stripe_token=) }
  it { should respond_to(:stripe_token) }
  it { should respond_to(:update_as_the_default_card) }

  describe 'Methods' do
    describe '.build_from_stripe_data' do
      context 'create SubscriptionPaymentCard data from stripe' do
        before do
          allow(User).to receive(:find).and_return(user)
          allow(Currency).to receive(:find_by_iso_code).and_return(user.currency)
        end

        it { expect(SubscriptionPaymentCard.build_from_stripe_data(payment_card, user.id)).to be(true) }
      end

      context "doesn't create SubscriptionPaymentCard data from stripe" do
        it do
          expect(Rails.logger).to receive(:error)
          expect(SubscriptionPaymentCard.build_from_stripe_data(payment_card)).to be(false)
        end
      end
    end

    describe '.create_from_stripe_array' do
      let(:stripe_card_array) { [{ object: 'card', id: 'card_guid' }] }

      before do
        subscription_payment_card.save
        allow(SubscriptionPaymentCard).to receive(:build_from_stripe_data).and_return(true)
        allow_any_instance_of(SubscriptionPaymentCard).to receive(:remove_card_from_stripe).and_return(true)
      end

      subject do
        SubscriptionPaymentCard.create_from_stripe_array(stripe_card_array, user.id, 'card_guid')
      end

      context 'create SubscriptionPaymentCard data from stripe array' do
        it { expect { subject }.to change { SubscriptionPaymentCard.count }.from(1).to(0) }
        it { expect(subject).to eq(stripe_card_array) }
      end
    end

    describe '#create_on_stripe_using_token' do
      let(:stripe_customer) { double(livemode: true, id: 'prod_12344') }

      context 'create on stripe' do
        before do
          allow(stripe_customer).to receive_message_chain(:sources, create: payment_card)
          allow(Stripe::Customer).to receive(:retrieve).and_return(stripe_customer)
          allow_any_instance_of(SubscriptionPaymentCard).to receive(:stripe_token).and_return(stripe_token)
          subscription_payment_card.user = stripe_user
          subscription_payment_card.stripe_card_guid = ''
        end

        it { expect(subscription_payment_card.create_on_stripe_using_token).to be(true) }
      end

      context 'not create on stripe' do
        before do
          allow_any_instance_of(SubscriptionPaymentCard).to receive(:stripe_token).and_return(stripe_token)
        end

        it do
          error_message = "ERROR: Could not find Stripe Token-#{subscription_payment_card.stripe_token} OR a customer id in the User-#{subscription_payment_card.user.stripe_customer_id}"
          expect(Rails.logger).to receive(:error).with(error_message)
          subscription_payment_card.create_on_stripe_using_token
        end
      end

      context 'not create on stripe' do
        before do
          allow(stripe_customer).to receive_message_chain(:sources, create: payment_card)
          allow(Stripe::Customer).to receive(:retrieve).and_return(nil)
          allow_any_instance_of(SubscriptionPaymentCard).to receive(:stripe_token).and_return(false)
          subscription_payment_card.user = stripe_user
          subscription_payment_card.stripe_card_guid = ''
        end

        it do
          error_message = "ERROR: Could not find Stripe Customer with-#{stripe_user.stripe_customer_id}. OR Stripe Create card failed with response-."
          expect(Rails.logger).to receive(:error).with(error_message)
          subscription_payment_card.create_on_stripe_using_token
        end
      end

      context 'not create on stripe' do
        before do
          allow(Stripe::Customer).to receive(:retrieve).and_raise(Stripe::CardError, 'message')
          allow_any_instance_of(SubscriptionPaymentCard).to receive(:stripe_token).and_return(stripe_token)
          subscription_payment_card.user = stripe_user
          subscription_payment_card.stripe_card_guid = ''
        end

        it do
          error_inpect = '#<ArgumentError: wrong number of arguments (given 1, expected 3)>'
          error_message = "ERROR: SubscriptionPaymentCard#create_on_stripe_using_token - error: #{error_inpect}.  Self: #{subscription_payment_card.inspect}."
          expect(Rails.logger).to receive(:error).with(error_message)
          subscription_payment_card.create_on_stripe_using_token
        end
      end

      context 'not create on stripe' do
        before do
          allow(Stripe::Customer).to receive(:retrieve).and_raise(Stripe::CardError)
          allow_any_instance_of(SubscriptionPaymentCard).to receive(:stripe_token).and_return(stripe_token)
          subscription_payment_card.user = stripe_user
          subscription_payment_card.stripe_card_guid = ''
        end

        xit do
          error_inpect = '#<ArgumentError: wrong number of arguments (given 1, expected 3)>'
          error_message = "ERROR: SubscriptionPaymentCard#create_on_stripe_using_token - error: #{error_inpect}.  Self: #{subscription_payment_card.inspect}."
          expect(Rails.logger).to receive(:error).with(error_message)
          subscription_payment_card.create_on_stripe_using_token
        end
      end
    end

    describe '#stripe_token=' do
      subject { subscription_payment_card.stripe_token=(stripe_token) }

      context 'set stripe_token to subscription_payment_card' do
        it { expect(subject).to eq(stripe_token) }
      end
    end

    describe '#update_as_the_default_card' do
      let(:stripe_customer) { double(livemode: true, id: 'prod_12344', default_source: '') }

      context 'expired card' do
        before do
          subscription_payment_card.status = 'expired'
          subject
        end

        subject { subscription_payment_card.update_as_the_default_card }

        context 'create SubscriptionPaymentCard data from stripe array' do
          error_message = I18n.t('models.subscription_payment_cards.card_has_expired')

          it { expect(subscription_payment_card.errors.messages[:base]).to eq([error_message]) }
          it { expect(subject).to be(true) }
        end
      end

      context 'not expired card' do
        before do
          allow(stripe_customer).to receive(:save).and_return(true)
          allow(stripe_customer).to receive(:default_source=).with(anything).and_return(anything)
          allow(Stripe::Customer).to receive(:retrieve).and_return(stripe_customer)
          allow_any_instance_of(SubscriptionPaymentCard).to receive(:delete_existing_default_cards).and_return(true)
          subject
        end

        subject do
          previous_payment_card.save
          subscription_payment_card.save
          subscription_payment_card.update_as_the_default_card
        end

        context 'create SubscriptionPaymentCard data from stripe array' do
          it { expect(subscription_payment_card.status).to eq('card-live') }
          it { expect(subscription_payment_card.is_default_card).to be(true) }

          it { expect(previous_payment_card.reload.status).to eq('not-live') }
          it { expect(previous_payment_card.reload.is_default_card).to be(false) }
        end
      end

      context 'not expired card and raise a error' do
        before do
          subject
        end

        subject do
          subscription_payment_card.update_as_the_default_card
        end

        context 'create SubscriptionPaymentCard data from stripe array' do
          it { expect(subscription_payment_card.errors.messages[:base]).to eq([I18n.t('models.subscriptions.upgrade_plan.processing_error_at_stripe')]) }
        end
      end
    end

    describe '#expiry_date' do
      subject { subscription_payment_card.expiry_date }

      context 'set stripe_token to subscription_payment_card' do
        it { expect(subject).to eq("#{subscription_payment_card.expiry_month}/#{subscription_payment_card.expiry_year}") }
      end
    end

    describe '#remove_card_from_stripe' do
      let(:error_retorned) { double(StandardError) }
      let(:error_message)  { "No such source: #{subscription_payment_card.stripe_card_guid}" }

      before do
        allow(error_retorned).to receive_message_chain(:response, data: { error: { message: error_message } })
        allow(Stripe::Customer).to receive(:retrieve).and_raise(error_retorned)
        subscription_payment_card.save
      end

      subject do
        previous_payment_card.destroy
      end

      context 'remove card from stripe before destroy' do
        xit 'trigger rescue' do
          expect(subject).to be(false)
          expect(subscription_payment_card.errors.messages[:base]).to eq([I18n.t('models.subscriptions.upgrade_plan.processing_error_at_stripe')])
        end
      end
    end

    describe '#delete_existing_default_cards' do
      before  { subscription_payment_card.save }
      subject { previous_payment_card.save }

      context 'destroy old card when save a new one' do
        it 'same count after save a new card' do
          expect(SubscriptionPaymentCard.count).to eq(1)
          subject
          expect(SubscriptionPaymentCard.count).to eq(1)
        end
      end
    end
  end
end
