class MixpanelUserSignUpWorker
  include Sidekiq::Worker
  require 'mixpanel-ruby'

  sidekiq_options queue: 'high'

  def perform(user_id, account_type, remote_ip)
    tracker = Mixpanel::Tracker.new(ENV['mixpanel_key'])
    tracker.people.set(user_id, { '$ip' => remote_ip })
    tracker.track(user_id, 'sign up', {
                    'account_type'       => account_type
                  })
    Rails.logger.debug "DEBUG: User#sign_up (student) mixpanel event for user #{user_id}. Tracker:#{tracker.inspect}."
  end

end
