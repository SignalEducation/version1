require 'rails_helper'

describe PaypalPlansService, type: :service do

  # INSTANCE METHODS ###########################################################

  describe 'subscription plans crud actions' do
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

  # PRIVATE METHODS ############################################################

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
end