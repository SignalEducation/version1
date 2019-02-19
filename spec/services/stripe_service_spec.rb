require 'rails_helper'

describe StripeService, type: :service do

  # INSTANCE METHODS ###########################################################

  # CUSTOMERS ==================================================================

  describe '#create_customer' do
    let(:user) { create(:user) }

    it 'creates the customer on Stripe' do
      expect(Stripe::Customer).to receive(:create).and_return(double(id: 'stripe_test_id'))

      subject.create_customer(user)
    end

    it 'updates the user with the Stripe customer id' do
      allow(Stripe::Customer).to receive(:create).and_return(double(id: 'stripe_test_id'))

      expect {
        subject.create_customer(user)
      }.to change { user.stripe_customer_id }.from(nil).to('stripe_test_id')
    end
  end

  describe '#get_customer' do
    it 'calls #retrieve on Stripe::Customer with the passed in Stripe ID' do
      expect(Stripe::Customer).to receive(:retrieve).with('stripe_test_id')

      subject.get_customer('stripe_test_id')
    end
  end

  # PLANS ======================================================================

  describe '#create_plan' do
    let(:plan) { build_stubbed(:subscription_plan) }

    it 'calls CREATE on Stripe::Plan with the correct args' do
      expect(Stripe::Plan).to receive(:create)
      allow(subject).to receive(:update_subscription_plan)

      subject.create_plan(plan)
    end

    it 'calls #update_subscription_plan with the correct args' do
      allow(Stripe::Plan).to receive(:create)
      expect(subject).to receive(:update_subscription_plan)

      subject.create_plan(plan)
    end
  end

  describe '#get_plan' do
    it 'calls #retrieve on Stripe::Plan with the correct args' do
      expect(Stripe::Plan).to receive(:retrieve).with({id: 'test_id'})

      subject.get_plan('test_id')
    end
  end

  describe '#update_plan' do
    let(:plan) { build_stubbed(:subscription_plan, stripe_guid: 'test_id') }

    before :each do
      @dbl = double
      allow(subject).to receive(:get_plan).with('test_id').and_return(@dbl)
      allow(@dbl).to receive(:name=)
      allow(@dbl).to receive(:save)
    end

    it 'calls #get_plan with the correct args' do
      expect(subject).to receive(:get_plan).with('test_id').and_return(@dbl)

      subject.update_plan(plan)
    end

    it 'calls #name= on the Plan with the correct args' do
      expect(@dbl).to receive(:name=).with("LearnSignal #{plan.name}")

      subject.update_plan(plan)
    end

    it 'calls #save on the Plan' do
      expect(@dbl).to receive(:save)

      subject.update_plan(plan)
    end
  end

  describe '#delete_plan' do
    let(:plan) { build_stubbed(:subscription_plan) }

    it 'calls #get_plan with the correct args' do
      dbl = double
      expect(subject).to receive(:get_plan).with('test_id').and_return(dbl)
      allow(dbl).to receive(:delete)

      subject.delete_plan('test_id')
    end

    it 'calls #delete on a Stripe plan if it exists' do
      dbl = double
      allow(subject).to receive(:get_plan).with('test_id').and_return(dbl)
      expect(dbl).to receive(:delete)

      subject.delete_plan('test_id')
    end

    it 'does not call #delete on a Stripe plan if it does not exist' do
      dbl = double
      allow(subject).to receive(:get_plan).with('test_id').and_return(nil)
      expect(dbl).not_to receive(:delete)

      subject.delete_plan('test_id')
    end
  end

  # SUBSCRIPTIONS ==============================================================

  describe '#change_plan' do
    it 'changes the plan'
  end

  describe '#create_and_return_subscription' do
    it 'creates and returns a subscription on Stripe'
  end

  describe '#pause_subscription' do
    let(:subscription) { create(:subscription, state: 'active') }

    before :each do
      allow_any_instance_of(SubscriptionPlanService).to receive(:queue_async)
      @dbl = double
      allow(Stripe::Subscription).to receive(:retrieve).with(subscription.stripe_guid).and_return(@dbl)
    end

    it 'requires a subscription to be passed in' do
      expect { subject.pause_subscription() }.to raise_error ArgumentError
    end

    it 'calls the Stripe API correctly' do
      expect(@dbl).to receive(:coupon=).with('paused-subscription')
      expect(@dbl).to receive(:save)

      subject.pause_subscription(subscription)
    end

    it 'updates the subscription state to PAUSED' do
      expect(@dbl).to receive(:coupon=).with('paused-subscription')
      allow(@dbl).to receive(:save)
      expect(subscription.state).to eq 'active'

      subject.pause_subscription(subscription)

      expect(subscription.state).to eq 'paused'
    end

    it 'handles an error from Stripe in updating the subscription' do
      allow(@dbl).to receive(:coupon=).with('paused-subscription')
      allow(@dbl).to receive(:save).and_raise(Stripe::StripeError)

      expect { subject.pause_subscription(subscription) }.to raise_error(Learnsignal::SubscriptionError)
    end
  end

  describe '#reactivate_subscription' do
    let(:subscription) { create(:subscription, state: 'paused') }

    before :each do
      allow_any_instance_of(SubscriptionPlanService).to receive(:queue_async)
      @dbl = double
      allow(Stripe::Subscription).to receive(:retrieve).with(subscription.stripe_guid).and_return(@dbl)
    end

    it 'requires a subscription to be passed in' do
      expect { subject.reactivate_subscription() }.to raise_error ArgumentError
    end

    it 'calls the Stripe API correctly' do
      expect(@dbl).to receive(:delete_discount)

      subject.reactivate_subscription(subscription)
    end

    it 'updates the subscription state to PAUSED' do
      allow(@dbl).to receive(:delete_discount)
      expect(subscription.state).to eq 'paused'

      subject.reactivate_subscription(subscription)

      expect(subscription.state).to eq 'active'
    end

    it 'handles an error from Stripe in updating the subscription' do
      allow(@dbl).to receive(:delete_discount).and_raise(Stripe::StripeError)

      expect { subject.reactivate_subscription(subscription) }.to raise_error(Learnsignal::SubscriptionError)
    end
  end

  # PRIVATE METHODS ============================================================

  describe 'async methods that communicate with PayPal / Stripe' do
    before :each do
      allow_any_instance_of(SubscriptionPlanService).to receive(:queue_async).and_return(true)
    end

    describe '#update_subscription_plan' do
      let(:plan) { create(:subscription_plan, paypal_state: 'CREATED') }
      let(:stripe_plan) { double({ id: 'plan_ff43br4535j4h53j' }) }

      it 'updates the stripe_guid of a subscription' do
        allow(stripe_plan).to receive(:[]).with(:livemode).and_return(true)
        expect(plan.stripe_guid).to be_nil

        subject.send(:update_subscription_plan, plan, stripe_plan)

        expect(plan.stripe_guid).to eq 'plan_ff43br4535j4h53j'
      end
    end
  end

  describe '#stripe_plan_id' do
    it 'should return a properly formatted id' do
      expect(subject.send(:stripe_plan_id)).to match 'test-'
    end
  end
end