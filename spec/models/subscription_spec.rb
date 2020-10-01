# == Schema Information
#
# Table name: subscriptions
#
#  id                       :integer          not null, primary key
#  user_id                  :integer
#  subscription_plan_id     :integer
#  stripe_guid              :string(255)
#  next_renewal_date        :date
#  complimentary            :boolean          default("false"), not null
#  stripe_status            :string(255)
#  created_at               :datetime
#  updated_at               :datetime
#  stripe_customer_id       :string(255)
#  livemode                 :boolean          default("false")
#  active                   :boolean          default("false")
#  terms_and_conditions     :boolean          default("false")
#  coupon_id                :integer
#  paypal_subscription_guid :string
#  paypal_token             :string
#  paypal_status            :string
#  state                    :string
#  cancelled_at             :datetime
#  cancellation_reason      :string
#  cancellation_note        :text
#  changed_from_id          :bigint
#  completion_guid          :string
#  ahoy_visit_id            :uuid
#  cancelled_by_id          :bigint
#  kind                     :integer
#  paypal_retry_count       :integer          default("0")
#

require 'rails_helper'

describe Subscription do
  before do
    Sidekiq::Testing.fake!
    Sidekiq::Worker.clear_all
    allow_any_instance_of(HubSpot::Contacts).to receive(:batch_create).and_return(:ok)
  end

  after do
    Sidekiq::Worker.drain_all
  end

  describe 'valid factory' do
    before :each do
      allow_any_instance_of(SubscriptionPlanService).to receive(:queue_async)
    end

    it 'should have a valid factory' do
      expect(build(:subscription)).to be_valid
    end
  end

  describe 'Constants' do
    it { expect(Subscription.const_defined?(:STATUSES)).to eq(true) }
  end

  describe 'Enums' do
    it do
      should define_enum_for(:kind).
               with(new_subscription: 0, reactivation: 1, change_plan: 2)
    end
  end

  describe 'Relationships' do
    it { should belong_to(:user) }
    it { should have_many(:invoices) }
    it { should have_many(:invoice_line_items) }
    it { should belong_to(:subscription_plan) }
    it { should belong_to(:coupon) }
    it { should have_many(:charges) }
    it { should have_many(:refunds) }
  end

  describe 'Validations' do
    it { should validate_presence_of(:kind) }
    it { should validate_presence_of(:user_id).on(:update) }
    it { should validate_presence_of(:subscription_plan_id) }
    it { should validate_inclusion_of(:stripe_status).in_array(Subscription::STATUSES).on(:update) }
    it { should validate_length_of(:stripe_guid).is_at_most(255) }
    it { should validate_length_of(:stripe_customer_id).is_at_most(255) }
  end

  describe 'Callbacks' do
    it { should callback(:create_subscription_payment_card).after(:create) }
    it { should callback(:update_coupon_count).after(:create) }
    it { should callback(:check_dependencies).before(:destroy) }
  end


  describe 'Scopes' do
    it { expect(Subscription).to respond_to(:all_in_order) }
    it { expect(Subscription).to respond_to(:in_created_order) }
    it { expect(Subscription).to respond_to(:in_reverse_created_order) }
    it { expect(Subscription).to respond_to(:all_of_status) }
    it { expect(Subscription).to respond_to(:all_active) }
    it { expect(Subscription).to respond_to(:all_valid) }
    it { expect(Subscription).to respond_to(:this_week) }
  end

  it { should respond_to(:cancel) }
  it { should respond_to(:immediate_cancel) }
  it { should respond_to(:reactivate_canceled) }
  it { should respond_to(:destroyable?) }
  it { should respond_to(:stripe_token) }
  it { should respond_to(:active_status?) }
  it { should respond_to(:canceled_status?) }
  it { should respond_to(:past_due_status?) }
  it { should respond_to(:unpaid_status?) }
  it { should respond_to(:canceled_pending_status?) }
  it { should respond_to(:billing_amount) }
  it { should respond_to(:reactivation_options) }
  it { should respond_to(:upgrade_options) }
  it { should respond_to(:update_from_stripe) }
  it { should respond_to(:un_cancel) }

  describe 'Methods' do
    describe '#update_from_stripe' do
      let(:sub) { build_stubbed(:subscription) }
      let(:stripe_sub) { create(:stripe_subscription) }

      before :each do
        allow_any_instance_of(SubscriptionPlanService).to receive(:queue_async)
      end

      it 'returns NIL unless there is a stripe_guid and stripe_customer_id present' do
        expect(sub.update_from_stripe).to be_nil
      end

      it 'returns NIL unless a stripe_customer is returned' do
        allow(Stripe::Customer).to receive(:retrieve).with(stripe_sub.stripe_customer_id).and_return(nil)

        expect(stripe_sub.update_from_stripe).to be_nil
      end

      it 'calls #update_subscription_attributes if there is a stripe_customer returned' do
        customer = double
        allow(Stripe::Customer).to receive(:retrieve).with(stripe_sub.stripe_customer_id).and_return(customer)
        expect(stripe_sub).to receive(:update_subscription_attributes).with(customer)

        stripe_sub.update_from_stripe
      end

      it 'rescues from Stripe::InvalidRequestError' do
        allow(Stripe::Customer).to receive(:retrieve).with(stripe_sub.stripe_customer_id).and_raise(Stripe::InvalidRequestError.new('message', 400))

        stripe_sub.update_from_stripe

        expect(stripe_sub.stripe_status).to eq 'canceled'
      end
    end

    describe '#update_subscription_attributes' do
      let(:sub) { create(:stripe_subscription, stripe_status: nil) }
      let(:customer) { double }
      let(:stripe_sub) do
        JSON.parse(
          File.read(
            Rails.root.join('spec/fixtures/stripe/create_subscription_response.json')
          ), object_class: OpenStruct
        )
      end

      before :each do
        allow_any_instance_of(SubscriptionPlanService).to receive(:queue_async)
        allow(stripe_sub).to receive(:id).and_return(sub.stripe_guid)
      end

      it 'retrieves the subscriptions for the customer' do
        expect(customer).to receive_message_chain('subscriptions.retrieve').and_return(stripe_sub)
        sub.update_subscription_attributes(customer)
      end

      it 'updates the subscription' do
        allow(customer).to receive_message_chain('subscriptions.retrieve').and_return(stripe_sub)

        expect {
          sub.update_subscription_attributes(customer)
          sub.reload
        }.to change { sub.next_renewal_date }.
          and change { sub.stripe_status }
      end
    end

    describe '#schedule_paypal_cancellation' do
      before :each do
        allow_any_instance_of(SubscriptionPlanService).to receive(:queue_async)
      end

      context 'for pending_cancellation subscriptions' do
        let(:subscription) { build_stubbed(:subscription, state: 'pending_cancellation')}

        it 'calls #set_cancellation_date on the subscription' do
          expect_any_instance_of(PaypalSubscriptionsService).to receive(:set_cancellation_date)

          subscription.schedule_paypal_cancellation
        end
      end

      context 'for active subscriptions' do
        let(:subscription) { create(:subscription, state: 'active')}

        it 'updates the state to #cancelled_pending' do
          allow_any_instance_of(PaypalSubscriptionsService).to receive(:set_cancellation_date)
          expect(subscription.state).to eq 'active'

          subscription.schedule_paypal_cancellation

          subscription.reload
          expect(subscription.state).to eq 'pending_cancellation'
        end

        it 'calls #set_cancellation_date on the subscription' do
          expect_any_instance_of(PaypalSubscriptionsService).to receive(:set_cancellation_date)

          subscription.schedule_paypal_cancellation
        end
      end
    end

    describe '#pending_3ds_invoice' do
      let(:subscription) { create(:subscription)}

      before :each do
        allow_any_instance_of(SubscriptionPlanService).to receive(:queue_async)
      end

      describe 'when no 3ds invoices exist' do
        let!(:invoice) { create(:invoice, subscription: subscription) }

        it 'returns nil' do
          expect(subscription.pending_3ds_invoice).to be_nil
        end
      end

      describe 'when a 3ds invoices exists' do
        let!(:invoice) {
          create(:invoice, subscription: subscription, requires_3d_secure: true)
        }

        it 'returns the first invoice' do
          expect(subscription.pending_3ds_invoice).to eq invoice
        end
      end
    end

    describe '#update_invoice_payment_success' do
      let(:subscription) { create(:subscription) }

      before :each do
        stripe_sub = double({
          status: 'canceled', current_period_end: Time.zone.now
        })
        allow_any_instance_of(StripeSubscriptionService).to(
          receive(:retrieve_subscription)
        ).and_return(stripe_sub)
        allow_any_instance_of(SubscriptionPlanService).to receive(:queue_async)
      end

      it 'updates the subscription stripe_status' do
        expect{ subscription.update_invoice_payment_success }.to(
          change{ subscription.stripe_status }
        )
      end

      it 'updates the subscription next_renewal_date' do
        expect{ subscription.update_invoice_payment_success }.to(
          change{ subscription.next_renewal_date }
        )
      end

      it 'starts a pending subscription' do
        expect(subscription).to receive(:start!)

        subscription.update_invoice_payment_success
      end

      it 'restarts an inactive subscription' do
        subscription.update(state: 'errored')
        expect(subscription).to receive(:restart!)

        subscription.update_invoice_payment_success
      end

      it 'does nothing with the state of an active subscription' do
        subscription.update(state: 'active')

        subscription.update_invoice_payment_success
        subscription.reload

        expect(subscription.state).to eq 'active'
      end
    end

    describe '#update_subscription_status' do
      before :each do
        allow_any_instance_of(SubscriptionPlanService).to receive(:queue_async)
      end

      describe 'when stripe_status is active' do
        let(:subscription) { create(:subscription, state: 'active') }

        it 'starts the subscription' do
          subscription.update(stripe_token: 'sdfgsdfghs')
          subscription.reload
          expect(subscription).to receive(:start)

          subscription.send(:update_subscription_status)
        end
      end

      describe 'when stripe_status is requires_action' do
        let(:subscription) {
          create(:subscription, payment_intent_status: 'requires_action')
        }

        it 'calls mark_payment_action_required transition' do
          subscription.update(stripe_token: 'sdfgsdfghs')
          subscription.reload
          expect(subscription).to receive(:start)

          subscription.send(:update_subscription_status)
        end
      end
    end

    describe '.update_hub_spot_data' do
      let(:user)   { build(:user) }
      let(:worker) { HubSpotContactWorker }

      context 'when user has updated data' do
        it 'create a job in HubSpotContactWorker' do
          user.update(first_name: Faker::Name.first_name)

          expect { worker.perform_async(rand(10)) }.to change(worker.jobs, :size).by(1)
        end
      end

      context 'when user has not updated data' do
        it 'do not create a job in HubSpotContactWorker' do
          user.update(last_request_at: Time.now)

          expect { worker.perform_async(rand(10)) }.to change(worker.jobs, :size).by(1)
        end
      end
    end
  end
end
