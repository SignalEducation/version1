class SubscriptionPlanWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'high'

  def perform(subscription_id, action)
    subscription = Subscription.find(subscription_id)
    SubscriptionService.new(subscription).async_action(action)
  end
end
