# frozen_string_literal: true

class SubscriptionCancellationWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'medium'

  def perform(subscription_id)
    subscription = Subscription.find(subscription_id)
    subscription.cancel! unless subscription.cancelled?
  end
end
