require 'rails_helper'

describe Paypal::SubscriptionValidation, type: :service do
  let(:subscription) { create(:paypal_subscription, paypal_status: 'Active') }
  let(:good_instance) { Paypal::SubscriptionValidation.new(subscription) }

  before :each do
    allow_any_instance_of(SubscriptionPlanService).to receive(:queue_async)
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
    let(:agreement_dbl) {
      double(
        'Agreement',
        id: 'I-ERW92H1T8T1ST',
        state: 'Active'
      )
    }
    let(:other_sub) { create(:paypal_subscription, paypal_status: 'Cancelled') }
    let(:bad_instance) { Paypal::SubscriptionValidation.new(other_sub) }

    it 'returns NIL if the PayPal agreement has the same state as the subscription' do
      allow(PayPal::SDK::REST::DataTypes::Agreement).to receive(:find).and_return(agreement_dbl)

      expect(good_instance.sync_with_paypal).to be nil
    end

    it 'calls #match_with_state if the state does not match' do
      allow(PayPal::SDK::REST::DataTypes::Agreement).to receive(:find).and_return(agreement_dbl)
      expect(bad_instance).to receive(:match_with_state).with(agreement_dbl)

      bad_instance.sync_with_paypal
    end
  end

  describe '#match_with_state' do
    describe 'for Active BillingAgreements' do
      it 'calls #restart on the subscription' do
        expect(subscription).to receive(:restart)

        good_instance.send(:match_with_state, double(state: 'Active'))
      end
    end

    describe 'for Suspended BillingAgreements' do
      it 'calls #pause on the subscription' do
        expect(subscription).to receive(:pause)

        good_instance.send(:match_with_state, double(state: 'Suspended'))
      end
    end

    describe 'for Cancelled BillingAgreements' do
      it 'calls #cancel on the subscription' do
        expect(subscription).to receive(:cancel)

        good_instance.send(:match_with_state, double(state: 'Cancelled'))
      end
    end
  end

  describe '#log_to_airbrake' do
    it 'calls #notify on Airbrake' do
      expect(Airbrake).to receive(:notify)

      good_instance.send(:log_to_airbrake)
    end
  end
end
