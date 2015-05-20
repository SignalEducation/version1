class MixpanelUserAliasWorker
  include Sidekiq::Worker
  require 'mixpanel-ruby'

  sidekiq_options queue: 'high'

  def perform(mixpanel_old_id, user_id)
    tracker = Mixpanel::Tracker.new(ENV['mixpanel_key'])
    tracker.alias(user_id, mixpanel_old_id)
    Rails.logger.debug "DEBUG: User aliased on Mixpanel after signup from #{mixpanel_old_id} to #{user_id}. Tracker:#{tracker.inspect}."
  end

end
