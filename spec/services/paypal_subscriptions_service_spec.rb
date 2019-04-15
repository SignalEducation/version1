require 'rails_helper'

describe PaypalSubscriptionsService, type: :service do

  # INSTANCE METHODS ###########################################################

  describe 'subscription crud actions' do
    let(:subscription_plan) { create(:subscription_plan) }

    before :each do
      allow_any_instance_of(SubscriptionPlanService).to receive(:queue_async)
    end

    describe '#create_plan' do
      it 'calls CREATE on an instance of PayPal::SDK::REST::DataTypes::Agreement::Plan' do
        allow_any_instance_of(PayPal::SDK::REST::DataTypes::Plan).to receive(:update)
        expect_any_instance_of(PayPal::SDK::REST::DataTypes::Plan).to receive(:create)

        subject.create_plan(subscription_plan)
      end

      it 'calls #update_subscription_plan' do
        allow_any_instance_of(PayPal::SDK::REST::DataTypes::Plan).to receive(:update)
        allow_any_instance_of(PayPal::SDK::REST::DataTypes::Plan).to receive(:create)
        expect(subject).to receive(:update_subscription_plan).with(subscription_plan, anything)

        subject.create_plan(subscription_plan)
      end

      it 'calls #update_subscription_plan_state' do
        allow_any_instance_of(PayPal::SDK::REST::DataTypes::Plan).to receive(:update).and_return(true)
        allow_any_instance_of(PayPal::SDK::REST::DataTypes::Plan).to receive(:create)
        expect(subject).to receive(:update_subscription_plan_state).with(subscription_plan, 'ACTIVE')

        subject.create_plan(subscription_plan)
      end
    end

    describe '#update_plan' do
      it 'calls #delete_plan followed by #create_plan' do
        expect(subject).to receive(:delete_plan)
        expect(subject).to receive(:create_plan)

        subject.update_plan(subscription_plan)
      end
    end

    describe '#delete_plan' do
      it 'calls FIND on an instance of PayPal::SDK::REST::DataTypes::Agreement::Plan' do
        dbl = double
        allow(dbl).to receive(:update)
        expect(PayPal::SDK::REST::DataTypes::Plan).to receive(:find).and_return(dbl)

        subject.delete_plan('stub_paypal_plan_id')
      end

      it 'calls UPDATE on an instance of PayPal::SDK::REST::DataTypes::Agreement::Plan' do
        dbl = double
        expect(dbl).to receive(:update)
        allow(PayPal::SDK::REST::DataTypes::Plan).to receive(:find).and_return(dbl)

        subject.delete_plan('stub_paypal_plan_id')
      end
    end
  end

  describe '#execute_billing_agreement' do
    let(:subscription) { create(:subscription) }

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
        state: 'PENDING'
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
      expect(PayPal::SDK::REST::DataTypes::Agreement).to receive(:find).and_return(@dbl)
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

  describe '#plan_attributes' do
    let(:plan) { build_stubbed(:subscription_plan) }

    it 'returns the correct hash' do
      expect(subject.send(:plan_attributes, plan))
        .to eq (
          {
            name: "LearnSignal #{plan.name}",
            description: plan.description,
            type: "INFINITE",
            payment_definitions: [
              {
                name: "Regular payment definition",
                type: "REGULAR",
                frequency: "MONTH",
                frequency_interval: plan.payment_frequency_in_months.to_s,
                amount: {
                  value: plan.price.to_s,
                  currency: plan.currency.iso_code
                },
                cycles: "0",
              }
            ],
            merchant_preferences: {
              setup_fee: {
                value: "0",
                currency: plan.currency.iso_code
              },
              return_url: "https://example.com",
              cancel_url: "https://example.com/cancel",
              auto_bill_amount: "YES",
              initial_fail_amount_action: "CANCEL",
              max_fail_attempts: "4"
            }
          }
        )
    end
  end

  describe '#patch' do
    before :each do
      allow_any_instance_of(PayPal::SDK::REST::DataTypes::Patch).to receive(:op=)
      allow_any_instance_of(PayPal::SDK::REST::DataTypes::Patch).to receive(:path=)
      allow_any_instance_of(PayPal::SDK::REST::DataTypes::Patch).to receive(:value=)
    end

    it 'sets the OP on the patch' do
      expect_any_instance_of(PayPal::SDK::REST::DataTypes::Patch).to receive(:op=)

      subject.send(:patch, 'CREATE', {})
    end

    it 'sets the path on the patch to /' do
      expect_any_instance_of(PayPal::SDK::REST::DataTypes::Patch).to receive(:path=)

      subject.send(:patch, 'CREATE', {})
    end

    it 'sets the value on the patch to the passed in attributes' do
      attributes = { attr_1: 'test_1', attr_2: 'test_2' }
      expect_any_instance_of(PayPal::SDK::REST::DataTypes::Patch).to receive(:value=).with(attributes)

      subject.send(:patch, 'CREATE', attributes)
    end

    it 'returns the patch object' do
      expect(subject.send(:patch, 'CREATE', {})).to be_instance_of(PayPal::SDK::REST::DataTypes::Patch)
    end
  end

  describe 'async methods that communicate with PayPal / Stripe' do
    before :each do
      allow_any_instance_of(SubscriptionPlanService).to receive(:queue_async).and_return(true)
    end

    describe '#update_subscription_plan' do
      let(:plan) { create(:subscription_plan, paypal_state: 'CREATED') }
      let(:paypal_plan) { double({ id: "PLAN-fdsfsdf43245423532", state: 'ACTIVE' }) }

      it 'updates the paypal_state of a subscription' do
        expect(plan.paypal_state).to eq 'CREATED'
        expect(plan.paypal_guid).to be_nil

        subject.send(:update_subscription_plan, plan, paypal_plan)

        expect(plan.paypal_state).to eq 'ACTIVE'
        expect(plan.paypal_guid).not_to be_nil
      end
    end

    describe '#update_subscription_plan_state' do
      let(:plan) { create(:subscription_plan, paypal_state: 'CREATED') }

      it 'updates the paypal_state of a subscription' do
        expect(plan.paypal_state).to eq 'CREATED'

        subject.send(:update_subscription_plan_state, plan, 'ACTIVE')

        expect(plan.paypal_state).to eq 'ACTIVE'
      end
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