require 'rails_helper'

describe Paypal::SubscriptionValidation, type: :service do
  before :each do
    allow_any_instance_of(SubscriptionPlanService).to receive(:queue_async)
  end

  describe '#sync_with_paypal' do
    let(:agreement_dbl) {
      double(
        'Agreement',
        id: 'I-ERW92H1T8T1ST',
        state: 'Active'
      )
    }
    let(:subscription) { create(:paypal_subscription, paypal_status: 'Active') }
    let(:other_sub) { create(:paypal_subscription, paypal_status: 'Cancelled') }
    let(:good_instance) { Paypal::SubscriptionValidation.new(subscription) }
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
end
