require 'rails_helper'

describe SubscriptionService, type: :service do
  let(:subscription) { build_stubbed(:subscription) }
  let(:sub_service) { SubscriptionService.new(subscription) }

  # INSTANCE METHODS ###########################################################

  describe '#change_plan' do
    describe 'for PayPal subscriptions' do
      before :each do
        allow(sub_service).to receive(:paypal?).and_return(true)
      end

      it 'no longer raises an error' do
        expect { sub_service.send(:change_plan, 'new_plan_id') }.not_to raise_error Learnsignal::SubscriptionError
      end
    end

    describe 'for Stripe subscriptions' do
      before :each do
        allow(sub_service).to receive(:paypal?).and_return(false)
        allow(subscription).to receive(:stripe_guid).and_return('test_guid')
      end

      it 'calls #change_plan on the StripeService' do
        expect_any_instance_of(StripeSubscriptionService).to receive(:change_plan).with('', 'new_plan_id')

        sub_service.send(:change_plan, 'new_plan_id')
      end
    end
  end

  describe '#check_for_valid_coupon?' do
    it 'returns NIL if the coupon code is blank' do
      expect(sub_service.check_for_valid_coupon?('')).to be nil
    end

    it 'raises an error if no coupon matches the code' do
      allow(Coupon).to receive(:get_and_verify).and_return(nil)

      expect { sub_service.check_for_valid_coupon?('code') }.to raise_error
    end

    it 'returns NIL if a valid coupon is present' do
      allow(Coupon).to receive(:get_and_verify).and_return(true)

      expect(sub_service.check_for_valid_coupon?('code')).to be nil
    end
  end

  describe '#check_valid_subscription?' do
    it 'returns TRUE if the #valid_paypal_subscription? is true' do
      allow(sub_service).to receive(:valid_paypal_subscription?).and_return(true)

      expect(sub_service.check_valid_subscription?({})).to be_truthy
    end

    it 'returns TRUE if the #valid_stripe_subscription? is true' do
      allow(sub_service).to receive(:valid_paypal_subscription?).and_return(false)
      allow(sub_service).to receive(:valid_stripe_subscription?).and_return(true)

      expect(sub_service.check_valid_subscription?({})).to be_truthy
    end

    it 'raises an error if neither #valid_paypal_subscription? or #valid_stripe_subscription? return true' do
      allow(sub_service).to receive(:valid_paypal_subscription?).and_return(false)
      allow(sub_service).to receive(:valid_stripe_subscription?).and_return(false)

      expect { sub_service.check_valid_subscription?({}) }.to raise_error
    end
  end

  describe '#un_cancel' do
    it 'returns FALSE unless the subscription is :pending_cancellation:' do
      expect(sub_service.send(:un_cancel)).to be false
    end

    describe 'for Stripe subscriptions' do
      let(:stripe_sub) { build_stubbed(:subscription, stripe_guid: 'test_guid', state: 'pending_cancellation') }
      let(:stripe_sub_service) { SubscriptionService.new(stripe_sub) }

      it 'returns FALSE unless the stripe_status is canceled-pending' do
        expect(stripe_sub_service.send(:un_cancel)).not_to be true
      end

      it 'calls Subscription#un_cancel for Stripe subscriptions that are canceled-pending' do
        expect(stripe_sub).to receive(:un_cancel)
        stripe_sub.stripe_status = 'canceled-pending'

        stripe_sub_service.send(:un_cancel)
      end
    end

    describe 'for Paypal Subscriptions' do
      let(:paypal_sub) {
        build_stubbed(:subscription, paypal_token: 'test_paypal_token', state: 'pending_cancellation')
      }
      let(:paypal_sub_service) { SubscriptionService.new(paypal_sub) }

      it 'calls PaypalSubscriptionsService#un_cancel for Paypal subscriptions' do
        expect_any_instance_of(PaypalSubscriptionsService).to receive(:un_cancel)

        paypal_sub_service.un_cancel
      end
    end
  end

  describe '#paypal?' do
    describe 'with :use_paypal param' do
      let(:paypal_sub) { build_stubbed(:subscription, use_paypal: 'true') }
      let(:paypal_sub_service) { SubscriptionService.new(paypal_sub) }

      it 'returns TRUE if :use_paypal is true' do
        expect(
          paypal_sub_service.send(:paypal?)
        ).to be true
      end
    end

    describe 'with paypal_token' do
      let(:paypal_sub) { build_stubbed(:subscription, paypal_token: 'true') }
      let(:paypal_sub_service) { SubscriptionService.new(paypal_sub) }

      it 'returns TRUE if :paypal_token is present' do
        expect(
          paypal_sub_service.send(:paypal?)
        ).to be true
      end
    end

    describe 'without paypal_token or use_paypal' do
      it 'returns FALSE' do
        expect(
          sub_service.send(:paypal?)
        ).to be false
      end
    end
  end

  describe '#stripe?' do
    describe 'with :stripe_guid present' do
      let(:stripe_sub) { build_stubbed(:subscription, stripe_guid: 'test_guid') }
      let(:stripe_sub_service) { SubscriptionService.new(stripe_sub) }

      it 'returns TRUE if :use_paypal is true' do
        expect(
          stripe_sub_service.send(:stripe?)
        ).to be true
      end
    end

    describe 'with stripe_token' do
      let(:stripe_sub) { build_stubbed(:subscription, stripe_token: 'test_token') }
      let(:stripe_sub_service) { SubscriptionService.new(stripe_sub) }

      it 'returns TRUE if :stripe_token is present' do
        expect(
          stripe_sub_service.send(:stripe?)
        ).to be true
      end
    end

    describe 'without stripe_token or stripe_guid' do
      let(:stripe_sub) { build(:subscription, stripe_guid: nil) }
      let(:stripe_sub_service) { SubscriptionService.new(stripe_sub) }

      it 'returns FALSE' do
        expect(
          sub_service.send(:stripe?)
        ).to be false
      end
    end
  end

  # PRIVATE METHODS ############################################################

  describe '#valid_paypal_subscription?' do
    it 'returns TRUE if :use_paypal is passed as a param' do
      expect(
        sub_service.send(:valid_paypal_subscription?, { subscription: { use_paypal: true } })
      ).to be true
    end

    it 'returns FALSE if :use_paypal is not passed as a param' do
      expect(
        sub_service.send(:valid_paypal_subscription?, { subscription: { another: true } })
      ).not_to be true
    end
  end

  describe '#valid_stripe_subscription?' do
    it 'returns TRUE if :stripe_token is passed as a param' do
      expect(
        sub_service.send(:valid_stripe_subscription?, { subscription: { stripe_token: true } })
      ).to be true
    end

    it 'returns FALSE if :stripe_token is not passed as a param' do
      expect(
        sub_service.send(:valid_stripe_subscription?, { subscription: { another: true } })
      ).not_to be true
    end
  end
end
