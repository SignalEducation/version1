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

      it 'raises an error' do
        expect { sub_service.send(:change_plan, 'new_plan_id') }.to raise_error Learnsignal::SubscriptionError
      end
    end

    describe 'for Stripe subscriptions' do
      before :each do
        allow(sub_service).to receive(:paypal?).and_return(false)
        allow(subscription).to receive(:stripe_guid).and_return('test_guid')
      end

      it 'calls #change_plan on the StripeService' do
        expect_any_instance_of(StripeService).to receive(:change_plan).with(subscription, 'new_plan_id')

        sub_service.send(:change_plan, 'new_plan_id')
      end
    end
  end

  describe '#check_for_valid_coupon?' do
    it 'does stuff'
  end

  describe '#pause' do
    describe 'for PayPal subscriptions' do
      before :each do
        allow(sub_service).to receive(:paypal?).and_return(true)
      end

      it 'calls #suspend_billing_agreement on the PaypalService' do
        expect_any_instance_of(PaypalService).to receive(:suspend_billing_agreement).with(subscription)

        sub_service.pause
      end
    end

    describe 'for Stripe subscriptions' do
      before :each do
        allow(sub_service).to receive(:stripe?).and_return(true)
      end

      it 'calls #pause_subscription on the StripeService' do
        expect_any_instance_of(StripeService).to receive(:pause_subscription).with(subscription)

        sub_service.pause
      end
    end
  end

  describe '#re_activate' do
    describe 'for PayPal subscriptions' do
      before :each do
        allow(sub_service).to receive(:paypal?).and_return(true)
      end

      it 'calls #reactivate_billing_agreement on the PaypalService' do
        expect_any_instance_of(PaypalService).to receive(:reactivate_billing_agreement).with(subscription)

        sub_service.re_activate
      end
    end

    describe 'for Stripe subscriptions' do
      before :each do
        allow(sub_service).to receive(:stripe?).and_return(true)
      end

      it 'calls #reactivate_subscription on the StripeService' do
        expect_any_instance_of(StripeService).to receive(:reactivate_subscription).with(subscription)

        sub_service.re_activate
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

#   def check_for_valid_coupon?(coupon_code)
#     if coupon_code.present?
#       unless @coupon = Coupon.get_and_verify(coupon_code, @subscription.subscription_plan_id)
#         raise Learnsignal::SubscriptionError.new('Sorry! That is not a valid coupon code.')
#       end
#     end
#   end

#   def create_and_return_subscription(params)
#     if self.stripe?
#       @subscription = StripeService.new.create_and_return_subscription(@subscription, params[:subscription][:stripe_token], @coupon)
#     elsif self.paypal?
#       @subscription.save!
#       @subscription = PaypalService.new.create_and_return_subscription(@subscription)
#     end
#   end

#   def check_valid_subscription?(params)
#     if valid_paypal_subscription?(params) || valid_stripe_subscription?(params)
#       true
#     else
#       raise Learnsignal::SubscriptionError.new('Sorry! The data entered is not valid. Please contact us for assistance.')
#     end
#   end

#   def validate_referral
#     if @subscription.user.referred_user?
#       @subscription.user.referred_signup.update(
#         payed_at: Time.zone.now,
#         subscription_id: @subscription.id
#       )
#     end
#   end