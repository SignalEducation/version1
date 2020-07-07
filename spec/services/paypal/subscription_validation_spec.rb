require 'rails_helper'

describe Paypal::SubscriptionValidation, type: :service do
  let(:agreement_dbl) {
    double(
      'Agreement',
      id: 'I-ERW92H1T8T1ST',
      state: 'Active'
    )
  }
  let(:subscription) { create(:paypal_subscription, paypal_status: 'Active', state: 'active') }
  let(:good_instance) { Paypal::SubscriptionValidation.new(subscription) }

  before :each do
    allow_any_instance_of(SubscriptionPlanService).to receive(:queue_async)
    allow(PayPal::SDK::REST::DataTypes::Agreement).to receive(:find).and_return(agreement_dbl)
  end

  describe 'class_methods' do
    describe '.run_paypal_sync' do
      before :each do
        create(:paypal_subscription, state: 'active')
      end

      it 'calls the correct scopes on the Subscription model' do
        expect(Subscription).to receive(:all_paypal).and_call_original
        expect(Subscription).to receive(:all_active).and_call_original
        expect_any_instance_of(ActiveRecord::Relation).to receive(:each)

        Paypal::SubscriptionValidation.run_paypal_sync
      end

      it 'calls #sync_with_paypal on a new instance for every subscription' do
        expect_any_instance_of(Paypal::SubscriptionValidation).to receive(:sync_with_paypal)

        Paypal::SubscriptionValidation.run_paypal_sync
      end
    end
  end

  describe '#sync_with_paypal' do
    let(:other_sub) { create(:paypal_subscription, paypal_status: 'Cancelled') }
    let(:bad_instance) { Paypal::SubscriptionValidation.new(other_sub) }

    it 'returns NIL if the PayPal agreement has the same state as the subscription' do
      allow(good_instance).to receive(:check_outstanding)
      expect(good_instance.sync_with_paypal).to be nil
    end

    it 'calls #match_with_state if the state does not match' do
      allow(bad_instance).to receive(:check_outstanding)
      expect(bad_instance).to receive(:match_with_state)

      bad_instance.sync_with_paypal
    end

    it 'calls #check_outstanding if the agreement is Active' do
      expect(bad_instance).to receive(:check_outstanding)
      allow(bad_instance).to receive(:match_with_state)

      bad_instance.sync_with_paypal
    end
  end

  describe '#match_with_state' do
    describe 'for Active BillingAgreements' do
      let(:sub) { create(:paypal_subscription, paypal_status: 'Suspended', state: 'paused') }
      let(:target_instance) { Paypal::SubscriptionValidation.new(sub) }

      it 'updates the subscription paypal status' do
        expect(sub).to receive(:update).with(paypal_status: 'Active')

        target_instance.send(:match_with_state)
      end

      it 'calls #restart on the subscription' do
        expect(sub).to receive(:restart!)

        target_instance.send(:match_with_state)
      end
    end

    describe 'for Suspended BillingAgreements' do
      let(:target_dbl) { double(state: 'Suspended') }
      let(:sub) { create(:paypal_subscription, paypal_status: 'Active', state: 'active') }
      let(:target_instance) { Paypal::SubscriptionValidation.new(sub) }

      before :each do
        allow(PayPal::SDK::REST::DataTypes::Agreement).to receive(:find).and_return(target_dbl)
      end

      it 'updates the subscription paypal status' do
        expect(sub).to receive(:update).with(paypal_status: 'Suspended')

        target_instance.send(:match_with_state)
      end

      it 'calls #pause on the subscription' do
        expect(sub).to receive(:pause!)

        target_instance.send(:match_with_state)
      end
    end

    describe 'for Cancelled BillingAgreements' do
      let(:target_dbl) { double(state: 'Cancelled') }
      let(:sub) { create(:paypal_subscription, paypal_status: 'Active', state: 'active') }
      let(:target_instance) { Paypal::SubscriptionValidation.new(sub) }

      before :each do
        allow(PayPal::SDK::REST::DataTypes::Agreement).to receive(:find).and_return(target_dbl)
      end

      it 'updates the subscription paypal status' do
        expect(target_instance).to receive(:update_paypal_status).with('Cancelled')

        target_instance.send(:match_with_state)
      end

      it 'calls #check_cancellation_status' do
        expect(target_instance).to receive(:check_cancellation_status)

        target_instance.send(:match_with_state)
      end
    end

    describe 'with an invalid state transition' do
      let(:target_dbl) { double(state: 'Suspended') }
      let(:sub) { create(:paypal_subscription, paypal_status: 'Suspended', state: 'paused') }
      let(:target_instance) { Paypal::SubscriptionValidation.new(sub) }

      before :each do
        allow(PayPal::SDK::REST::DataTypes::Agreement).to receive(:find).and_return(target_dbl)
      end

      it 'logs to airbrake' do
        allow(target_instance).to receive(:update_paypal_status).and_raise(StateMachines::InvalidTransition.new(sub, Subscription.state_machine, 'cancel_pending'))
        expect(target_instance).to receive(:log_to_airbrake)

        target_instance.send(:match_with_state)
      end
    end
  end

  describe '#check_suspended_status' do
    let(:target_dbl) { double(state: 'Suspended') }

    before :each do
      allow(PayPal::SDK::REST::DataTypes::Agreement).to receive(:find).and_return(target_dbl)
    end

    describe 'for subscriptions pending cancellation' do
      let(:sub) { create(:paypal_subscription, paypal_status: 'Suspended', state: 'pending_cancellation') }
      let(:target_instance) { Paypal::SubscriptionValidation.new(sub) }

      it 'calls #check_scheduled_cancellation_worker' do
        expect(target_instance).to receive(:check_scheduled_cancellation_worker)

        target_instance.send(:check_suspended_status)
      end
    end

    describe 'for non pending cancellation subscriptions' do
      let(:sub) { create(:paypal_subscription, paypal_status: 'Suspended', state: 'active') }
      let(:target_instance) { Paypal::SubscriptionValidation.new(sub) }

      it 'calls #pause on the subscription' do
        expect(sub).to receive(:pause!)

        target_instance.send(:check_suspended_status)
      end
    end
  end

  describe '#check_scheduled_cancellation_worker' do
    let(:sub) { create(:paypal_subscription, paypal_status: 'Suspended', state: 'active') }
    let(:target_instance) { Paypal::SubscriptionValidation.new(sub) }
    let(:target_dbl) { double(state: 'Suspended') }

    before :each do
      allow(PayPal::SDK::REST::DataTypes::Agreement).to receive(:find).and_return(target_dbl)
    end

    it 'calls #cancel_billing_agreement_immediately on PaypalSubscriptionsService' do
      expect_any_instance_of(PaypalSubscriptionsService).to receive(:cancel_billing_agreement_immediately)

      target_instance.send(:check_scheduled_cancellation_worker)
    end

    it 'returns nil if there are no scheduled workers' do
      allow_any_instance_of(Sidekiq::ScheduledSet).to receive(:select).and_return([1])

      expect(target_instance.send(:check_scheduled_cancellation_worker)).to be nil
    end
  end

  describe '#check_cancellation_status' do
    let(:target_dbl) { double(state: 'Cancelled') }
    let(:sub) { create(:paypal_subscription, paypal_status: 'Active', state: 'active') }
    let(:target_instance) { Paypal::SubscriptionValidation.new(sub) }
    let(:pending_cancellation_sub) { create(:paypal_subscription, paypal_status: 'Active', state: 'pending_cancellation') }
    let(:pending_instance) { Paypal::SubscriptionValidation.new(pending_cancellation_sub) }

    before :each do
      allow(PayPal::SDK::REST::DataTypes::Agreement).to receive(:find).and_return(target_dbl)
    end

    describe 'for pending_cancellation subscriptions' do
      it 'does not call #cancel on the subscription if the next_renewal_date is in the future' do
        pending_cancellation_sub.update(next_renewal_date: Time.zone.now + 1.week)
        expect(pending_cancellation_sub).not_to receive(:cancel!)

        pending_instance.send(:match_with_state)
      end

      it 'calls #cancel on the subscription if the next_renewal_date is not in the future' do
        pending_cancellation_sub.update(next_renewal_date: Time.zone.now - 1.week)
        expect(pending_cancellation_sub).to receive(:cancel!)

        pending_instance.send(:match_with_state)
      end
    end

    describe 'for non-pending_cancellation subscriptions' do
      it 'calls #cancel on the subscription' do
        expect(sub).to receive(:cancel!)

        target_instance.send(:match_with_state)
      end
    end
  end

  describe '#check_outstanding' do
    let(:target_dbl) { double(state: 'Active') }
    let(:sub) { create(:paypal_subscription, paypal_status: 'Active', state: 'active') }
    let(:target_instance) { Paypal::SubscriptionValidation.new(sub) }

    before :each do
      allow(PayPal::SDK::REST::DataTypes::Agreement).to receive(:find).and_return(target_dbl)
    end

    it 'creates an instance of Paypal::SubscriptionRecovery' do
      expect(Paypal::SubscriptionRecovery).to receive(:new).with(sub, target_dbl).and_return(double(outstanding_balance?: false))

      target_instance.send(:check_outstanding)
    end

    it 'calls #bill_outstanding on the instance if there is an outstanding balance' do
      recovery = double(outstanding_balance?: true)
      allow(Paypal::SubscriptionRecovery).to receive(:new).with(sub, target_dbl).and_return(recovery)
      expect(recovery).to receive(:bill_outstanding)

      target_instance.send(:check_outstanding)
    end
  end

  describe '#update_paypal_status' do
    let(:sub) { create(:paypal_subscription, paypal_status: 'Active', state: 'active') }
    let(:target_instance) { Paypal::SubscriptionValidation.new(sub) }

    it 'calls #update with the passed in state' do
      expect(sub).to receive(:update).with(paypal_status: 'Cancelled')

      target_instance.send(:update_paypal_status, 'Cancelled')
    end
  end

  describe '#log_to_airbrake' do
    it 'calls #notify on Airbrake' do
      expect(Airbrake).to receive(:notify)

      good_instance.send(:log_to_airbrake, 'test message')
    end
  end
end
