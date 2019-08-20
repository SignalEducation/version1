class SubscriptionPlanWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'high'

  def perform(subscription_plan_id, action, stripe_guid=nil, paypal_guid=nil)
    if action == 'delete'
      StripePlanService.new.delete_plan(stripe_guid)
      PaypalPlansService.new.delete_plan(paypal_guid)
    else
      plan = SubscriptionPlan.find(subscription_plan_id)
      SubscriptionPlanService.new(plan).async_action(action)
    end
  end
end
