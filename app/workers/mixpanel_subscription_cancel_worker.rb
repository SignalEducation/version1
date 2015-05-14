class MixpanelSubscriptionCancelWorker
  include Sidekiq::Worker
  require 'mixpanel-ruby'

  sidekiq_options queue: 'high'

  def perform(subscription_id)
    sub = Subscription.find_by_id(subscription_id)
    if sub
      user_transactions = SubscriptionTransaction.includes(:currency).where(user_id: sub.user_id)

      tracker = Mixpanel::Tracker.new(ENV['mixpanel_key'])
      tracker.track(sub.user_id, 'Subscription Cancelled', {
                      'Times Charged' => user_transactions.select { |ut| ut.transaction_type != 'trialing' }.length,
                      'Amount Charged' => user_transactions.inject(0) { |sum, ut| ut.transaction_type == 'payment' ? sum + ut.amount : sum },
                      'Currency' => user_transactions.last.currency.iso_code,
                      'Plan' => I18n.t("views.student_sign_ups.form.payment_frequency_in_months.a#{sub.subscription_plan.payment_frequency_in_months}")
                    })
      Rails.logger.debug "DEBUG: Subscription Canceled event sent to Mixpanel. Tracker:#{tracker.inspect}."
    end
  end
end
