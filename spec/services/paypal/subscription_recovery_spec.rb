require 'rails_helper'

describe Paypal::SubscriptionRecovery, type: :service do
  let(:agreement_dbl) {
    double(
      'Agreement',
      id: 'I-ERW92H1T8T1ST',
      state: 'Active'
    )
  }
  let(:subscription) { create(:paypal_subscription, paypal_status: 'Active', state: 'active') }
  subject { Paypal::SubscriptionRecovery.new(subscription, agreement_dbl) }

  before :each do
    allow_any_instance_of(SubscriptionPlanService).to receive(:queue_async)
  end

  describe 'initialization' do
    it 'does not get the agreement object from PayPal' do
      expect(PayPal::SDK::REST::DataTypes::Agreement).not_to receive(:find)

      Paypal::SubscriptionRecovery.new(subscription, agreement_dbl)
    end
  end

  describe '#outstanding_balance?' do
    it 'calls #positive? on the return value of outstanding_balance' do
      balance = double(positive?: true)
      allow(subject).to receive(:outstanding_balance).and_return(balance)
      expect(balance).to receive(:positive?)

      subject.outstanding_balance?
    end
  end

  describe '#outstanding_balance' do
    it 'returns the outstanding_balance from paypal' do
      balance = double(value: '0.0')
      allow(agreement_dbl).to receive_message_chain('agreement_details.outstanding_balance').and_return(balance)

      expect(subject.outstanding_balance).to eq 0.0
    end
  end

  describe '#bill_outstanding' do
    it 'calls #process_recovery_success if the PayPal agreement updates' do
      allow(agreement_dbl).to receive_message_chain('agreement_details.outstanding_balance').and_return('0.0')
      allow(agreement_dbl).to receive(:bill_balance).and_return(true)
      expect(subject).to receive(:process_recovery_success)

      subject.bill_outstanding
    end

    it 'calls #process_recovery_failure if the PayPal agreement fails to update' do
      allow(agreement_dbl).to receive_message_chain('agreement_details.outstanding_balance').and_return('0.0')
      allow(agreement_dbl).to receive(:bill_balance).and_return(false)
      expect(subject).to receive(:process_recovery_failure)

      subject.bill_outstanding
    end
  end

  describe '#process_recovery_failure' do
    it 'marks the subscription past_due if it is not aleardy in that state' do
      expect(subscription).to receive(:mark_past_due)

      subject.send(:process_recovery_failure)
    end

    it 'does not call mark_past_due on the sub if it is aleardy in that state' do
      allow(subscription).to receive(:past_due?).and_return(true)
      expect(subscription).not_to receive(:mark_past_due)

      subject.send(:process_recovery_failure)
    end

    it 'increments the :paypal_retry_count on the subscription' do
      expect { subject.send(:process_recovery_failure) }.to change { subscription.paypal_retry_count }.from(0).to(1)
    end

    it 'returns NIL if the :paypal_retry_count is less than 8' do
      expect(subject.send(:process_recovery_failure)).to be nil
    end

    it 'calls #cancel_billing_agreement_immediately on a subscription instance if the :paypal_retry_count is not less than 8' do
      subscription.update(paypal_retry_count: 7)
      expect_any_instance_of(PaypalSubscriptionsService).to receive(:cancel_billing_agreement_immediately)

      subject.send(:process_recovery_failure)
    end
  end

  describe '#process_recovery_success' do
    it 'restarts the subscription if the subscription is not active' do
      subscription.update(state: 'past_due')
      expect(subscription).to receive(:restart)

      subject.send(:process_recovery_success)
    end

    it 'does not restart the subscription if the subscription is active' do
      expect(subscription).not_to receive(:restart)

      subject.send(:process_recovery_success)
    end

    it 'sets the retry count back to zero' do
      subscription.update(paypal_retry_count: 7)

      expect { subject.send(:process_recovery_success) }.to change { subscription.paypal_retry_count }.from(7).to(0)
    end
  end
end
