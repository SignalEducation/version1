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
#  changed_from_id          :bigint(8)
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
      expect(create(:subscription)).to be_valid
    end
  end

  # Constants
  it { expect(Subscription.const_defined?(:STATUSES)).to eq(true) }

  # relationships
  it { should belong_to(:user) }
  it { should have_many(:invoices) }
  it { should have_many(:invoice_line_items) }
  it { should belong_to(:subscription_plan) }
  it { should belong_to(:coupon).optional }
  it { should have_one(:student_access) }
  it { should have_many(:subscription_transactions) }
  it { should have_many(:charges) }
  it { should have_many(:refunds) }

  # validation
  it { should validate_presence_of(:user_id).on(:update) }

  it { should validate_presence_of(:subscription_plan_id) }

  it { should validate_inclusion_of(:stripe_status).in_array(Subscription::STATUSES).on(:update) }

  it { should validate_length_of(:stripe_guid).is_at_most(255) }
  it { should validate_length_of(:stripe_customer_id).is_at_most(255) }

  # callbacks
  it { should callback(:create_subscription_payment_card).after(:create) }
  it { should callback(:update_coupon_count).after(:create) }
  it { should callback(:check_dependencies).before(:destroy) }

  # scopes
  it { expect(Subscription).to respond_to(:all_in_order) }
  it { expect(Subscription).to respond_to(:in_created_order) }
  it { expect(Subscription).to respond_to(:in_reverse_created_order) }
  it { expect(Subscription).to respond_to(:all_of_status) }
  it { expect(Subscription).to respond_to(:all_active) }
  it { expect(Subscription).to respond_to(:all_valid) }
  it { expect(Subscription).to respond_to(:this_week) }

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
