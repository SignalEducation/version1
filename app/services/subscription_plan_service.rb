class SubscriptionPlanService
  attr_accessor :subscription_plan

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
    case action
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
    StripService.new.create_plan
    PaypalService.new.create_plan
  end

  def update_remote_plans
    StripService.new.update_plan
    PaypalService.new.update_plan
  end

  def delete_remote_plans
    StripService.new.delete_plan
    PaypalService.new.delete_plan
  end
end