require 'rails_helper'

describe Paypal::Subscription, type: :service do
  describe 'CONSTANTS' do
    it 'has a STATES constant' do
      expect(Paypal::Subscription::STATUSES).to eq({ 'Active' => 'active',
                                                     'Suspended' => 'paused',
                                                     'Cancelled' => 'cancelled' })
    end
  end

  describe 'initialization' do
    let(:agreement_dbl) {
      double(
        'Agreement',
        id: 'I-ERW92H1T8T1ST',
        state: 'Active'
      )
    }
    let(:subscription) { create(:paypal_subscription, paypal_status: 'Active', state: 'active', paypal_subscription_guid: 'test_paypal_guid') }

    before :each do
      allow_any_instance_of(SubscriptionPlanService).to receive(:queue_async)
      allow(PayPal::SDK::REST::DataTypes::Agreement).to receive(:find).and_return(agreement_dbl)
    end

    it 'gets the agreement object from PayPal' do
      expect(PayPal::SDK::REST::DataTypes::Agreement).to receive(:find).with('test_paypal_guid')

      Paypal::Subscription.new(subscription)
    end
  end
end
