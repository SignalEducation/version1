class StripeService

  def create_plan(subscription_plan)
    stripe_plan = Stripe::Plan.create(
      amount: (subscription_plan.price.to_f * 100).to_i,
      currency: subscription_plan.currency.iso_code.downcase,
      interval: 'month',
      interval_count: subscription_plan.payment_frequency_in_months,
      name: 'LearnSignal ' + subscription_plan.name,
      statement_descriptor: 'LearnSignal',
      id: stripe_plan_id
    )
    update_subscription_plan(subscription_plan, stripe_plan)
  end

  def get_plan(plan_id)
    plan = Stripe::Plan.retrieve({ id: plan_id })
  end

  def delete_plan(plan_id)
    plan = get_plan(plan_id)
    plan.delete if plan
  rescue Stripe::InvalidRequestError => e
    return false
  end

  private

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
