class MixpanelUserSignUpWorker
  include Sidekiq::Worker
  require 'mixpanel-ruby'

  sidekiq_options queue: 'high'

  def perform(user_id, remote_ip)
    tracker = Mixpanel::Tracker.new(ENV['mixpanel_key'])
    tracker.track(user_id, 'sign up', {})
    tracker.people.set(user_id, { '$ip' => remote_ip })
    Rails.logger.debug "DEBUG: User#sign_up (student) mixpanel event for user #{user_id}. Tracker:#{tracker.inspect}."
  end

end
