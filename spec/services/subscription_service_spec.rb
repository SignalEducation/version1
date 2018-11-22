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

  # PRIVATE METHODS ############################################################

  describe '#valid_paypal_subscription?' do
    it 'does stuff'
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

#   def paypal?
#     (@subscription.use_paypal.present? && @subscription.use_paypal == 'true') || @subscription.paypal_token.present?
#   end

#   def stripe?
#     @subscription.stripe_token.present? || @subscription.stripe_guid.present?
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

#   private

#   def valid_paypal_subscription?(params)
#     params[:subscription][:use_paypal].present? &&
#       @subscription &&
#       @subscription.subscription_plan
#   end

#   def valid_stripe_subscription?(params)
#     params[:subscription][:stripe_token].present? &&
#       @subscription &&
#       @subscription.subscription_plan
#   end