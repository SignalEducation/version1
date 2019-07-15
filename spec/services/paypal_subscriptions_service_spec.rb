require 'rails_helper'

describe PaypalSubscriptionsService, type: :service do
  before :each do
    allow_any_instance_of(SubscriptionPlanService).to receive(:queue_async)
  end
  let(:subscription) { create(:subscription) }
  subject { PaypalSubscriptionsService.new(subscription) }

  # INSTANCE METHODS ###########################################################

  describe '#execute_billing_agreement' do
    let(:agreement_dbl) {
      double(
        'Agreement',
        id: 'I-ERW92H1T8T1ST',
        state: 'Active'
      )
    }

    it 'must have a subscription' do
      expect { subject.execute_billing_agreement }.to raise_error ArgumentError
    end

    it 'must have a token' do
      expect { subject.execute_billing_agreement }.to raise_error ArgumentError
      expect { subject.execute_billing_agreement('token') }.not_to raise_error ArgumentError
    end

    it 'calls EXECUTE on an instance of PayPal Agreement' do
      expect_any_instance_of(PayPal::SDK::REST::DataTypes::Agreement).to receive(:execute).and_return(true)
      expect_any_instance_of(PayPal::SDK::REST::DataTypes::Agreement).to receive(:token=)

      subject.execute_billing_agreement('token')
    end

    it 'accurately updates the subscription' do
      allow_any_instance_of(PayPal::SDK::REST::DataTypes::Agreement).to receive(:execute).and_return(true)
      allow_any_instance_of(PayPal::SDK::REST::DataTypes::Agreement).to receive(:state).and_return('Active')
      allow_any_instance_of(PayPal::SDK::REST::DataTypes::Agreement).to receive(:id).and_return('AGREEMENT_ID')

      expect {
        subject.execute_billing_agreement('dummy_token')
      }.to change { subscription.paypal_status }.from(nil).to('Active')
       .and change { subscription.paypal_subscription_guid }.from(nil).to('AGREEMENT_ID')
    end
  end

  describe '#create_and_return_subscription' do
    let(:agreement_dbl) {
      double(
        'Agreement',
        token: 'tok_FDAF343DFDA',
        links: [double( rel: 'approval_url', href: 'https://example.com/approval' )],
        state: 'Pending'
      )
    }

    it 'calls the #create_billing_agreement method' do
      expect(subject).to receive(:create_billing_agreement).and_return(agreement_dbl)

      subject.create_and_return_subscription
    end

    it 'returns an updated subscription object with the PayPal attributes' do
      allow(subject).to receive(:create_billing_agreement).and_return(agreement_dbl)
      expect(subscription.paypal_token).to be_nil
      expect(subscription.paypal_approval_url).to be_nil
      expect(subscription.paypal_status).to be_nil

      subject.create_and_return_subscription

      expect(subscription.paypal_token).not_to be_nil
      expect(subscription.paypal_approval_url).not_to be_nil
      expect(subscription.paypal_status).not_to be_nil
    end
  end

  describe '#create_billing_agreement' do
    it 'calls CREATE on an instance of PayPal Agreement' do
      expect_any_instance_of(PayPal::SDK::REST::DataTypes::Agreement).to receive(:create).and_return(true)

      subject.send(:create_billing_agreement, subscription: subscription)
    end
  end

  describe '#cancel_billing_agreement' do
    before :each do
      @dbl = double
      allow(@dbl).to receive(:state).and_return('Cancelled')
    end

    it 'calls FIND on an instance of PayPal::SDK::REST::DataTypes::Agreement::Plan' do
      expect(PayPal::SDK::REST::DataTypes::Agreement).to receive(:find).and_return(@dbl)
      allow(@dbl).to receive(:cancel).and_return(true)

      subject.cancel_billing_agreement
    end

    it 'calls CANCEL on an instance of PayPal::SDK::REST::DataTypes::Agreement::Plan' do
      expect(@dbl).to receive(:cancel).and_return(true)
      allow(PayPal::SDK::REST::DataTypes::Agreement).to receive(:find).and_return(@dbl)

      subject.cancel_billing_agreement
    end

    it 'updates the state of the subscription to PENDING_CANCELLATION' do
      allow(PayPal::SDK::REST::DataTypes::Agreement).to receive(:find).and_return(@dbl)
      allow(@dbl).to receive(:cancel).and_return(true)
      new_subscription = create(:subscription, state: 'active')

      PaypalSubscriptionsService.new(new_subscription).cancel_billing_agreement

      new_subscription.reload
      expect(new_subscription.state).to eq 'pending_cancellation'
    end
  end

  describe '#change_plan' do
    it 'changes the plan the user is on'
  end

  # PRIVATE METHODS ############################################################

  describe '#agreement_attributes' do
    it 'returns the correct hash' do
      expect(subject.send(:agreement_attributes, subscription: subscription))
        .to eq (
          {
            name: subscription.subscription_plan.name,
            description: subscription.subscription_plan.description.gsub("\n", ""),
            start_date: (Time.zone.now + subscription.subscription_plan.payment_frequency_in_months.months).iso8601,
            payer: {
              payment_method: "paypal",
              payer_info: {
                email: subscription.user.email,
                first_name: subscription.user.first_name,
                last_name: subscription.user.last_name
              }
            },
            override_merchant_preferences: {
              setup_fee: {
                value: subscription.subscription_plan.price.to_s,
                currency: subscription.subscription_plan.currency.iso_code
              },
              return_url: "https://staging.learnsignal.com/en/subscriptions/#{subscription.id}/execute?payment_processor=paypal",
              cancel_url: "https://staging.learnsignal.com/en/subscriptions/new?flash=It+seems+you+cancelled+your+subscription+on+Paypal.+Still+want+to+upgrade%3F"
            },
            plan: {
              id: subscription.subscription_plan.paypal_guid
            }
          }
        )
    end
  end

  describe '#learnsignal_host' do
    describe 'non-production ENVs' do
      it 'returns the correct host' do
        expect(subject.send(:learnsignal_host))
          .to eq 'https://staging.learnsignal.com'
      end
    end

    describe 'production ENV' do
      before :each do
        Rails.env.stub(:production? => true)
      end

      it 'returns the correct host' do
        expect(subject.send(:learnsignal_host)).to eq 'https://learnsignal.com'
      end
    end
  end
end
