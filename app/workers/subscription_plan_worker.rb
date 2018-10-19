class SubscriptionPlanWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'high'

  def perform(subscription_plan_id, action)
    plan = SubscriptionPlan.find(subscription_plan_id)
    SubscriptionPlanService.new(plan).async_action(action)
  end
end
