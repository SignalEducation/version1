# frozen_string_literal: true

class SubscriptionService
  attr_reader :subscription, :coupon

  def initialize(subscription)
    @subscription = subscription
    @coupon = nil
  end

  def change_plan(new_plan_id)
    if paypal?
      PaypalSubscriptionsService.new(@subscription).change_plan(new_plan_id)
    elsif stripe?
      StripeService.new.change_plan(@subscription, new_plan_id)
    end
  end

  def check_for_valid_coupon?(coupon_code)
    return if coupon_code.blank?

    @coupon = Coupon.get_and_verify(coupon_code, @subscription.subscription_plan_id)
    return if @coupon.nil?

    raise Learnsignal::SubscriptionError.new('Sorry! That is not a valid coupon code.')
  end

  def create_and_return_subscription(params)
    if stripe?
      @subscription, _client_secret = StripeService.new.create_and_return_subscription(@subscription, params[:subscription][:stripe_token], @coupon)
    elsif paypal?
      @subscription.save!
      @subscription = PaypalSubscriptionsService.new(@subscription).create_and_return_subscription
      [@subscription, nil]
    end
  end

  def cancel_subscription
    if paypal?
      PaypalSubscriptionsService.new(@subscription).cancel_billing_agreement
    elsif stripe?
      StripeService.new.cancel_subscription(@subscription)
    end
  end

  def cancel_subscription_immediately
    if paypal?
      PaypalSubscriptionsService.new(@subscription).cancel_billing_agreement_immediately
    elsif stripe?
      StripeService.new.cancel_subscription_immediately(@subscription)
    end
  end

  def paypal?
    (@subscription.use_paypal.present? && @subscription.use_paypal == 'true') || @subscription.paypal_token.present?
  end

  def stripe?
    @subscription.stripe_token.present? || @subscription.stripe_guid.present?
  end

  def check_valid_subscription?(params)
    return true if valid_paypal_subscription?(params) || valid_stripe_subscription?(params)

    raise Learnsignal::SubscriptionError.new('Sorry! The data entered is not valid. Please contact us for assistance.')
  end

  def validate_referral
    return unless @subscription.user.referred_user?

    @subscription.user.referred_signup.update(payed_at: Time.zone.now,
                                              subscription_id: @subscription.id)
  end

  private

  def valid_paypal_subscription?(params)
    params[:subscription][:use_paypal].present? &&
      @subscription &&
      @subscription.subscription_plan.present?
  end

  def valid_stripe_subscription?(params)
    params[:subscription][:stripe_token].present? &&
      @subscription &&
      @subscription.subscription_plan.present?
  end
end
