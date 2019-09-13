# frozen_string_literal: true

class StripePlanService
  def create_plan(subscription_plan)
    stripe_plan = create_stripe_plan(subscription_plan)
    subscription_plan.update(
      stripe_guid: stripe_plan.id,
      livemode: stripe_plan[:livemode]
    )
  end

  def update_plan(subscription_plan)
    stripe_plan              = get_plan(subscription_plan.stripe_guid)
    stripe_plan.product.name = "LearnSignal #{subscription_plan.name}"
    stripe_plan.product.save
  end

  def delete_plan(stripe_plan_id)
    plan = get_plan(stripe_plan_id)
    plan&.delete
  end

  private

  def create_stripe_plan(plan)
    Stripe::Plan.create(
      amount: (plan.price.to_f * 100).to_i,
      currency: plan.currency.iso_code.downcase,
      interval: 'month',
      interval_count: plan.payment_frequency_in_months,
      product: {
        name: "LearnSignal #{plan.name}",
        statement_descriptor: 'LearnSignal'
      }, id: stripe_plan_id
    )
  end

  def get_plan(stripe_plan_id)
    Stripe::Plan.retrieve(id: stripe_plan_id, expand: ['product'])
  end

  def stripe_plan_id
    Rails.env + '-' + ApplicationController.generate_random_code(20)
  end
end
