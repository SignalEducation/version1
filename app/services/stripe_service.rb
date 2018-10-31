class StripeService

  # CUSTOMERS ==================================================================

  def create_customer(user)
    customer = Stripe::Customer.create(email: user.email)
    user.update(stripe_customer_id: customer.id)
    customer
  end

  def get_customer(stripe_customer_id)
    Stripe::Customer.retrieve(stripe_customer_id)
  end

  # PLANS ======================================================================

  def create_plan(subscription_plan)
    stripe_plan = Stripe::Plan.create(
      amount: (subscription_plan.price.to_f * 100).to_i,
      currency: subscription_plan.currency.iso_code.downcase,
      interval: 'month',
      interval_count: subscription_plan.payment_frequency_in_months,
      name: "LearnSignal #{subscription_plan.name}",
      statement_descriptor: 'LearnSignal',
      id: stripe_plan_id
    )
    update_subscription_plan(subscription_plan, stripe_plan)
  end

  def get_plan(stripe_plan_id)
    plan = Stripe::Plan.retrieve({ id: stripe_plan_id })
  end

  def update_plan(subscription_plan)
    plan = get_plan(subscription_plan.stripe_guid)
    plan.name = "LearnSignal #{subscription_plan.name}"
    plan.save
  end

  def delete_plan(stripe_plan_id)
    plan = get_plan(stripe_plan_id)
    plan.delete if plan
  end

  # SUBSCRIPTIONS ==============================================================

  def create_and_return_subscription(subscription, stripe_token, coupon)
    stripe_subscription = create_subscription(subscription, stripe_token, coupon)
    stripe_customer = Stripe::Customer.retrieve(subscription.user.stripe_customer_id)
    subscription.assign_attributes(
      complimentary: false,
      active: true,
      livemode: stripe_subscription[:plan][:livemode],
      current_status: stripe_subscription.status,
      stripe_guid: stripe_subscription.id,
      next_renewal_date: Time.at(stripe_subscription.current_period_end),
      stripe_customer_id: stripe_customer.id,
      coupon_id: coupon.try(:id),
      stripe_customer_data: stripe_customer.to_hash.deep_dup
    )
    subscription
  end

  private

  def create_subscription(subscription, stripe_token, coupon)
    Stripe::Subscription.create(
      customer: subscription.user.stripe_customer_id,
      items: [{
        plan: subscription.subscription_plan.stripe_guid,
        quantity: 1
      }],
      source: stripe_token,
      coupon: coupon.try(:code),
      trial_end: 'now'
    )
  rescue Stripe::CardError => e
    body = e.json_body
    err  = body[:error]
    Rails.logger.error "DEBUG: Subscription#create Card Declined with - Status: #{e.http_status}, Type: #{err[:type]}, Code: #{err[:code]}, Param: #{err[:param]}, Message: #{err[:message]}"
    raise Learnsignal::SubscriptionError.new("Sorry! Your request was declined because - #{err[:message]}")
  rescue => e
    Rails.logger.error "DEBUG: Subscription#create Failure for unknown reason - Error: #{e.inspect}"
    raise Learnsignal::SubscriptionError.new('Sorry Something went wrong! Please contact us for assistance.')
  end

  def update_subscription_plan(subscription_plan, stripe_plan)
    subscription_plan.update(
      stripe_guid: stripe_plan.id,
      livemode: stripe_plan[:livemode]
    )    
  end

  def stripe_plan_id
    Rails.env + '-' + ApplicationController::generate_random_code(20)
  end
end
