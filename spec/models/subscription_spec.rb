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

describe Subscription do

  describe 'valid factory' do
    before :each do
      allow_any_instance_of(SubscriptionPlanService).to receive(:queue_async)
    end

    it 'should have a valid factory' do
      expect(build(:subscription)).to be_valid
    end
  end

  # Constants
  it { expect(Subscription.const_defined?(:STATUSES)).to eq(true) }

  # relationships
  it { should belong_to(:user) }
  it { should have_many(:invoices) }
  it { should have_many(:invoice_line_items) }
  it { should belong_to(:subscription_plan) }
  it { should belong_to(:coupon) }
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

  # class methods

  # instance methods

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

end
