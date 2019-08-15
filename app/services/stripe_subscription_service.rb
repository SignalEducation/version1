# frozen_string_literal: true

class StripeSubscriptionService < StripeService
  def initialize(subscription)
    @subscription = subscription
  end

  def retrieve_subscription
    Stripe::Subscription.retrieve(id: @subscription.stripe_guid)
  end

  def change_plan(new_plan_id)
    new_subscription_plan = SubscriptionPlan.find(new_plan_id)

    new_subscription = create_new_subscription(new_subscription_plan)
    new_subscription.start
    update_old_subscription(new_subscription)
    new_subscription
  end

  def create_and_return_subscription(stripe_token, coupon)
    customer = Stripe::Customer.update(@subscription.user.stripe_customer_id,
                                       source: stripe_token)

    stripe_subscription = create_stripe_subscription(customer.id, coupon)
    client_secret       = stripe_subscription.latest_invoice[:payment_intent][:client_secret]
    subscription_object = merge_subscription_data(stripe_subscription, customer, coupon)
    [subscription_object, { client_secret: client_secret, status: :ok }]
  rescue Stripe::CardError => e
    [subscription_object, { error: e, error_message: e.message, status: :error }]
  end

  def cancel_subscription(immediately: false)
    if !@subscription.stripe_customer_id || !@subscription.stripe_guid
      raise_subscription_error({}, __method__.to_s, :sub_cancellation)
    end

    stripe_subscription = cancel_stripe_subscription(period_end: !immediately)
    @subscription.update(stripe_status: stripe_subscription.status)
    immediately ? @subscription.cancel : @subscription.cancel_pending
  end

  private

  def cancel_stripe_subscription(period_end: true)
    stripe_subscription = retrieve_subscription
    if period_end
      stripe_subscription.cancel_at_period_end = period_end
      stripe_subscription.save
    else
      stripe_subscription.delete
    end
  rescue Stripe::StripeError => e
    raise_subscription_error(e, __method__.to_s, :sub_cancellation)
  end

  def create_new_subscription(new_plan)
    stripe_sub = get_updated_stripe_subscription(new_plan)
    Subscription.create!(
      user_id: @subscription.user_id, subscription_plan_id: new_plan.id,
      complimentary: false, livemode: stripe_sub.plan[:livemode],
      stripe_status: stripe_sub.status, changed_from: @subscription,
      stripe_guid: stripe_sub.id, next_renewal_date: renewal_date(stripe_sub),
      stripe_customer_id: @subscription.stripe_customer_id
    )
  rescue ActiveRecord::RecordInvalid, StandardError => e
    raise_subscription_error(e, __method__.to_s, :sub_change)
  end

  def create_stripe_subscription(stripe_customer_id, coupon)
    Stripe::Subscription.create(
      customer: stripe_customer_id,
      items: [{ plan: @subscription.subscription_plan.stripe_guid,
                quantity: 1 }],
      coupon: coupon.try(:code), trial_end: 'now',
      expand: ['latest_invoice.payment_intent']
    )
  rescue Stripe::CardError => e
    raise_subscription_error(e.json_body[:error], __method__.to_s, :decline)
  end

  def get_updated_stripe_subscription(new_sub_plan)
    stripe_sub = retrieve_subscription
    Stripe::Subscription.update(
      @subscription.stripe_guid,
      items: { id: stripe_sub&.items&.first&.id, plan: new_sub_plan.stripe_guid },
      prorate: true
    )
  rescue Stripe::CardError => e
    raise_subscription_error(e.json_body[:error], __method__.to_s, :generic)
  end

  def merge_subscription_data(stripe_sub, customer, coupon)
    @subscription.assign_attributes(
      complimentary: false, livemode: stripe_sub.plan[:livemode],
      stripe_status: stripe_sub.status,
      stripe_guid: stripe_sub.id, next_renewal_date: renewal_date(stripe_sub),
      stripe_customer_id: customer.id, coupon_id: coupon.try(:id),
      stripe_customer_data: customer.to_hash.deep_dup,
      payment_intent: stripe_sub.latest_invoice[:payment_intent][:status]
    )

    @subscription
  end

  def renewal_date(stripe_sub)
    Time.zone.at(stripe_sub.current_period_end)
  end

  def update_old_subscription(new_subscription)
    @subscription.user.student_access.update(
      subscription_id: new_subscription.id, account_type: 'Subscription',
      content_access: true
    )
    @subscription.update(stripe_status: 'canceled', state: 'cancelled')
  end
end
