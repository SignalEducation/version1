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
    end
  end

  private

  def create_remote_plans
    StripePlanService.new.create_plan(@plan)
    PaypalPlansService.new.create_plan(@plan)
  end

  def update_remote_plans
    StripePlanService.new.update_plan(@plan)
    PaypalPlansService.new.update_plan(@plan)
  end
end