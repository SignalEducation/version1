require 'rails_helper'

describe PaypalSubscriptionsService, type: :service do

  # INSTANCE METHODS ###########################################################

  describe '#execute_billing_agreement' do
    let(:subscription) { create(:subscription) }
    let(:agreement_dbl) { 
      double(
        'Agreement', 
        id: 'I-ERW92H1T8T1ST',
        state: 'Active'
      )
    }

    before :each do
      allow_any_instance_of(SubscriptionPlanService).to receive(:queue_async)
    end

    it 'must have a subscription' do
      expect { subject.execute_billing_agreement() }.to raise_error ArgumentError
    end

    it 'must have a token' do
      expect { subject.execute_billing_agreement(subscription) }.to raise_error ArgumentError
      expect { subject.execute_billing_agreement(subscription, 'token') }.not_to raise_error ArgumentError   
    end

    it 'calls EXECUTE on an instance of PayPal Agreement' do
      expect_any_instance_of(PayPal::SDK::REST::DataTypes::Agreement).to receive(:execute).and_return(true)
      expect_any_instance_of(PayPal::SDK::REST::DataTypes::Agreement).to receive(:token=)

      subject.execute_billing_agreement(subscription, 'token')
    end

    it 'accurately updates the subscription' do
      allow_any_instance_of(PayPal::SDK::REST::DataTypes::Agreement).to receive(:execute).and_return(true)
      allow_any_instance_of(PayPal::SDK::REST::DataTypes::Agreement).to receive(:state).and_return('Active')
      allow_any_instance_of(PayPal::SDK::REST::DataTypes::Agreement).to receive(:id).and_return('AGREEMENT_ID')

      expect {
        subject.execute_billing_agreement(subscription, 'dummy_token')
      }.to change { subscription.paypal_status }.from(nil).to('Active')
       .and change { subscription.active }.from(false).to(true)
       .and change { subscription.paypal_subscription_guid }.from(nil).to('AGREEMENT_ID')
    end
  end

  describe '#create_and_return_subscription' do
    let(:subscription) { build_stubbed(:subscription) }
    let(:agreement_dbl) { 
      double(
        'Agreement', 
        token: 'tok_FDAF343DFDA', 
        links: [double( rel: 'approval_url', href: 'https://example.com/approval' )],
        state: 'Pending'
      )
    }

    it 'calls the #create_billing_agreement method' do
      expect(subject).to receive(:create_billing_agreement).with(subscription).and_return(agreement_dbl)

      subject.create_and_return_subscription(subscription)
    end

    it 'returns an updated subscription object with the PayPal attributes' do
      allow(subject).to receive(:create_billing_agreement).with(subscription).and_return(agreement_dbl)
      expect(subscription.paypal_token).to be_nil
      expect(subscription.paypal_approval_url).to be_nil
      expect(subscription.paypal_status).to be_nil

      subject.create_and_return_subscription(subscription)

      expect(subscription.paypal_token).not_to be_nil
      expect(subscription.paypal_approval_url).not_to be_nil
      expect(subscription.paypal_status).not_to be_nil
    end
  end

  describe '#create_billing_agreement' do
    before :each do
      allow_any_instance_of(SubscriptionPlanService).to receive(:queue_async)
    end
    let!(:subscription) { create(:subscription) }

    it 'calls CREATE on an instance of PayPal Agreement' do
      expect_any_instance_of(PayPal::SDK::REST::DataTypes::Agreement).to receive(:create).and_return(true)

      subject.create_billing_agreement(subscription)
    end
  end

  describe '#suspend_billing_agreement' do
    before :each do
      allow_any_instance_of(SubscriptionPlanService).to receive(:queue_async)
      @dbl = double
      allow(@dbl).to receive(:state).and_return('Suspended')
    end

    let!(:subscription) { create(:subscription) }

    it 'must have a subscription' do
      expect { subject.suspend_billing_agreement() }.to raise_error ArgumentError
    end

    it 'calls FIND on an instance of PayPal::SDK::REST::DataTypes::Agreement::Plan' do
      expect(PayPal::SDK::REST::DataTypes::Agreement).to receive(:find).twice.and_return(@dbl)
      allow(@dbl).to receive(:suspend).and_return(true)

      subject.suspend_billing_agreement(subscription)
    end

    it 'calls SUSPEND on an instance of PayPal::SDK::REST::DataTypes::Agreement::Plan' do
      expect(@dbl).to receive(:suspend).and_return(true)
      allow(PayPal::SDK::REST::DataTypes::Agreement).to receive(:find).and_return(@dbl)

      subject.suspend_billing_agreement(subscription)
    end

    it 'updates the state of the subscription to PAUSED' do
      allow(PayPal::SDK::REST::DataTypes::Agreement).to receive(:find).and_return(@dbl)
      allow(@dbl).to receive(:suspend).and_return(true)
      new_subscription = create(:subscription, state: 'active')

      subject.suspend_billing_agreement(new_subscription)

      new_subscription.reload
      expect(new_subscription.state).to eq 'paused'
    end
  end

  describe '#reactivate_billing_agreement' do
    before :each do
      allow_any_instance_of(SubscriptionPlanService).to receive(:queue_async)
      @dbl = double
      allow(@dbl).to receive(:state).and_return('Active')
    end

    let!(:subscription) { create(:subscription) }

    it 'must have a subscription' do
      expect { subject.reactivate_billing_agreement() }.to raise_error ArgumentError
    end

    it 'calls FIND on an instance of PayPal::SDK::REST::DataTypes::Agreement::Plan' do
      allow(@dbl).to receive(:re_activate).and_return(true)
      expect(PayPal::SDK::REST::DataTypes::Agreement).to receive(:find).and_return(@dbl)

      subject.reactivate_billing_agreement(subscription)
    end

    it 'calls SUSPEND on an instance of PayPal::SDK::REST::DataTypes::Agreement::Plan' do
      expect(@dbl).to receive(:re_activate).and_return(true)
      allow(PayPal::SDK::REST::DataTypes::Agreement).to receive(:find).and_return(@dbl)

      subject.reactivate_billing_agreement(subscription)
    end

    it 'updates the state of the subscription to ACTIVE' do
      allow(PayPal::SDK::REST::DataTypes::Agreement).to receive(:find).and_return(@dbl)
      allow(@dbl).to receive(:re_activate).and_return(true)
      new_subscription = create(:subscription, state: 'paused')

      subject.reactivate_billing_agreement(new_subscription)

      new_subscription.reload
      expect(new_subscription.state).to eq 'active'
    end
  end

  describe '#cancel_billing_agreement' do
    before :each do
      allow_any_instance_of(SubscriptionPlanService).to receive(:queue_async)
      @dbl = double
      allow(@dbl).to receive(:state).and_return('Cancelled')
    end

    let!(:subscription) { create(:subscription) }

    it 'must have a subscription' do
      expect { subject.cancel_billing_agreement() }.to raise_error ArgumentError
    end

    it 'calls FIND on an instance of PayPal::SDK::REST::DataTypes::Agreement::Plan' do
      expect(PayPal::SDK::REST::DataTypes::Agreement).to receive(:find).and_return(@dbl)
      allow(@dbl).to receive(:cancel).and_return(true)

      subject.cancel_billing_agreement(subscription)
    end

    it 'calls CANCEL on an instance of PayPal::SDK::REST::DataTypes::Agreement::Plan' do
      expect(@dbl).to receive(:cancel).and_return(true)
      allow(PayPal::SDK::REST::DataTypes::Agreement).to receive(:find).and_return(@dbl)

      subject.cancel_billing_agreement(subscription)
    end

    it 'updates the state of the subscription to PENDING_CANCELLATION' do
      allow(PayPal::SDK::REST::DataTypes::Agreement).to receive(:find).and_return(@dbl)
      allow(@dbl).to receive(:cancel).and_return(true)
      new_subscription = create(:subscription, state: 'active')

      subject.cancel_billing_agreement(new_subscription)

      new_subscription.reload
      expect(new_subscription.state).to eq 'pending_cancellation'
    end
  end

  # PRIVATE METHODS ############################################################

  describe '#agreement_attributes' do
    let(:subscription) { build_stubbed(:subscription) }

    it 'returns the correct hash' do
      expect(subject.send(:agreement_attributes, subscription))
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
              cancel_url: "https://staging.learnsignal.com/en/new_subscription?flash=It+seems+you+cancelled+your+subscription+on+Paypal.+Still+want+to+upgrade%3F"
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