require 'rails_helper'

describe PaypalService, type: :service do

  describe 'subscription crud actions' do
    describe '#create_plan' do
      it 'does stuff'
    end

    describe '#update_plan' do
      it 'does stuff'
    end

    describe '#delete_plan' do
      it 'does stuff'
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

    it 'starts the subscription' do
      allow_any_instance_of(PayPal::SDK::REST::DataTypes::Agreement).to receive(:execute).and_return(true)
      expect(subscription.state).to eq 'pending'

      subject.execute_billing_agreement(subscription, 'dummy_token')

      subscription.reload
      expect(subscription.state).to eq 'active'
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
    it 'calls the correct paypal REST API method'
  end

  describe '#reactivate_billing_agreement' do
    it 'calls the correct paypal REST API method'
  end

  describe '#cancel_billing_agreement' do
    it 'calls the correct paypal REST API method'
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

  # describe '#patch' do
  #   let(:)
  # end

  # def patch(op, update_attributes)
  #   patch = Patch.new
  #   patch.op = op
  #   patch.path = "/"
  #   patch.value = update_attributes
  #   patch
  # end  

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
        expect(plan.paypal_state).not_to be_nil
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