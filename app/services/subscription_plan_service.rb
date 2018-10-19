class SubscriptionPlanService
  attr_accessor :subscription_plan

  def initialize(subscription_plan)
    @subscription_plan = subscription_plan
  end

  def queue_async(action: :create)
    SubscriptionPlanWorker.perform_async(
      @subscription_plan.id,
      action
    )
  end

  def async_action(action)
    case action
    when :create
      create_plan
    when :delete
      delete_plan
    end
  end

  private

  def create_plan
    StripService.new.create_plan
    PaypalService.new.create_plan
  end
end