# frozen_string_literal: true

class StripeSubscriptionService < StripeService
  def initialize(subscription)
    @subscription = subscription
  end

  def retrieve_subscription(id: nil, **options)
    Stripe::Subscription.retrieve(id: (id || @subscription.stripe_guid), **options)
  end

  def change_plan(plan_id)
    if (new_sub = @subscription.changed_to) && new_sub.pending_3d_secure?
      stripe_sub = retrieve_subscription(id: new_sub.stripe_guid, expand: ['latest_invoice.payment_intent'])
      new_sub.client_secret = stripe_sub.latest_invoice[:payment_intent][:client_secret]
    else
      new_sub, stripe_sub = create_subscription(SubscriptionPlan.find(plan_id))
      update_old_subscription(new_sub)
      new_sub.take_appropriate_action(stripe_sub.status)
    end
    [new_sub, { status: :ok }]
  end

  def create_and_return_subscription(stripe_token, coupon)
    customer = Stripe::Customer.update(@subscription.user.stripe_customer_id,
                                       source: stripe_token)

    stripe_subscription = create_stripe_subscription(customer.id, coupon)
    subscription_object = merge_subscription_data(stripe_subscription, customer)
    [subscription_object, { status: :ok }]
  rescue Stripe::CardError => e
    raise_subscription_error(e, __method__.to_s, :custom, e.message)
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

  def create_subscription(new_plan)
    stripe_sub = get_updated_stripe_subscription(new_plan)
    [Subscription.create!(
      user_id: @subscription.user_id, subscription_plan_id: new_plan.id,
      complimentary: false, livemode: stripe_sub.plan[:livemode],
      stripe_status: stripe_sub.status, changed_from: @subscription,
      stripe_guid: stripe_sub.id, next_renewal_date: renewal_date(stripe_sub),
      stripe_customer_id: @subscription.stripe_customer_id,
      client_secret: stripe_sub.latest_invoice[:payment_intent][:client_secret]
    ), stripe_sub]
  end

  def create_stripe_subscription(stripe_customer_id, coupon)
    Stripe::Subscription.create(
      customer: stripe_customer_id,
      items: [{ plan: @subscription.subscription_plan.stripe_guid,
                quantity: 1 }],
      coupon: coupon.try(:code), trial_end: 'now',
      expand: ['latest_invoice.payment_intent']
    )
  rescue Stripe::CardError, Stripe::StripeError => e
    raise_subscription_error(e.json_body[:error], __method__.to_s, :decline)
  end

  def get_updated_stripe_subscription(new_sub_plan)
    stripe_sub = retrieve_subscription
    Stripe::Subscription.update(
      @subscription.stripe_guid,
      items: [{ id: stripe_sub&.items&.first&.id, plan: new_sub_plan.stripe_guid }],
      prorate: true, expand: ['latest_invoice.payment_intent']
    )
  rescue Stripe::StripeError => e
    raise_subscription_error(e.json_body[:error], __method__.to_s, :generic)
  end

  def merge_subscription_data(stripe_sub, customer)
    @subscription.assign_attributes(
      complimentary: false, livemode: stripe_sub.plan[:livemode],
      stripe_status: stripe_sub.status, stripe_customer_id: customer.id,
      next_renewal_date: renewal_date(stripe_sub), stripe_guid: stripe_sub.id,
      stripe_customer_data: customer.to_hash.deep_dup,
      payment_intent_status: stripe_sub.latest_invoice[:payment_intent][:status],
      client_secret: stripe_sub.latest_invoice[:payment_intent][:client_secret]
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