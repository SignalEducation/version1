class SubscriptionPlanService
  attr_reader :plan

  def initialize(subscription_plan)
    @plan = subscription_plan
  end

  def queue_async(action)
    SubscriptionPlanWorker.perform_async(
      @plan.id,
      action
    )
  end

  def async_action(action)
    case action.to_sym
    when :create
      create_remote_plans
    when :update
      update_remote_plans
    when :delete
      delete_remote_plans
    end
  end

  private

  def create_remote_plans
    StripeService.new.create_plan(@plan)
    PaypalSubscriptionsService.new.create_plan(@plan)
  end

  def update_remote_plans
    StripeService.new.update_plan(@plan)
    PaypalSubscriptionsService.new.update_plan(@plan)
  end

  def delete_remote_plans
    StripeService.new.delete_plan(@plan.stripe_guid)
    PaypalSubscriptionsService.new.delete_plan(@plan.paypal_guid)
  end
end