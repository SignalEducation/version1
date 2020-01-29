# frozen_string_literal: true

class PaypalSubscriptionCancellationWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'medium'

  def perform(subscription_id)
    subscription = Subscription.find(subscription_id)
    return unless subscription.pending_cancellation?

    PaypalSubscriptionsService.new(subscription).cancel_billing_agreement_immediately
  end
end
