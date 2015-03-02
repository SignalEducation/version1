class SubscriptionDeferredCancellerWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'medium'

  def perform(subscription_id)
    sub = Subscription.find_by_id(subscription_id)
    if sub
      if sub.current_status == 'canceled-pending'
        sub.update_attribute(:current_status, 'canceled')
        Rails.logger.info "INFO: SubscriptionDeferredCancellerWorker - subscription #{subscription_id} cancelled OK."
      else
        Rails.logger.error "ERROR: SubscriptionDeferredCancellerWorker - subscription #{subscription_id} was NOT cancelled because its status was not set correctly - its status was '#{sub.current_status}'."
      end
    else
      Rails.logger.error "ERROR: SubscriptionDeferredCancellerWorker - subscription #{subscription_id} was NOT cancelled because it could not be found using its ID."
    end
  end

end
