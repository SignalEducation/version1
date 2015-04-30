class MixpanelSubscriptionUpdateWorker
  include Sidekiq::Worker
  require 'mixpanel-ruby'

  sidekiq_options queue: 'high'

  def perform(user_id, old_plan_name, new_plan_name)
    tracker1 = Mixpanel::Tracker.new(ENV['mixpanel_key'])
    tracker1.people.set(user_id, {
            'old_plan_name'       => old_plan_name,
            'subscription_plan'   => new_plan_name,
            'subscription_plan_updated_at' => Proc.new{Time.now}.call.strftime('%Y-%b-%d %H:%M:%S %Z')
    })
    Rails.logger.debug "DEBUG: Subscription#send_update_event_to_mixpanel updated a user's subscription. Tracker:#{tracker1.inspect}."
    tracker2 = Mixpanel::Tracker.new(mixpanel_token)
    tracker2.track(user_id, 'subscription updated', {
            'old_plan_name'   => old_plan_name,
            'new_plan_name'   => new_plan_name
    })
    Rails.logger.debug "DEBUG: Subscription#send_update_event_to_mixpanel logged a user's subscription change. Tracker:#{tracker2.inspect}."
  end

end
