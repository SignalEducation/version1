class SubscriptionService
  attr_reader :subscription, :coupon

  def initialize(subscription)
    @subscription = subscription
    @coupon = nil
  end

  def check_for_valid_coupon?(coupon_code)
    if coupon_code.present?
      unless @coupon = Coupon.get_and_verify(coupon_code, @subscription.subscription_plan_id)
        raise Learnsignal::SubscriptionError.new('Sorry! That is not a valid coupon code.')
      end
    end
  end

  def create_and_return_subscription(params)
    if @subscription.stripe?
      @subscription = StripeService.new.create_and_return_subscription(@subscription, params[:subscription][:stripe_token], @coupon)
    elsif @subscription.paypal?
      @subscription = PaypalService.new.create_and_return_subscription(@subscription)
    end
  end

  def paypal?
    @subscription.use_paypal.present?
  end

  def stripe?
    @subscription.stripe_token.present? || @subscription.stripe_guid.present?
  end

  def check_valid_subscription?(params)
    if valid_paypal_subscription?(params) || valid_stripe_subscription?(params)
      true
    else
      raise Learnsignal::SubscriptionError.new('Sorry! The data entered is not valid. Please contact us for assistance.')
    end
  end

  def validate_referral
    if @subscription.user.referred_user?
      @subscription.user.referred_signup.update(
        payed_at: Time.zone.now,
        subscription_id: @subscription.id
      )
    end
  end

  private

  def valid_paypal_subscription?(params)
    params[:subscription][:stripe_token].present? &&
      @subscription &&
      @subscription.subscription_plan
  end

  def valid_stripe_subscription?(params)
    params[:subscription][:stripe_token].present? &&
      @subscription &&
      @subscription.subscription_plan
  end
end