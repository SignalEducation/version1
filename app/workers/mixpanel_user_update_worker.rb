class MixpanelUserUpdateWorker
  include Sidekiq::Worker
  require 'mixpanel-ruby'

  sidekiq_options queue: 'high'

  def perform(user_details_hash)
    mixpanel_token = Rails.env.production? ?  '362a1cbd7dc8a587c8e0ccb891f8fd8f' : 'adf0d15829ee2f8e588aef51a1193e3d'
    tracker = Mixpanel::Tracker.new(mixpanel_token)
    tracker.people.set(user_details_hash['id'], {
            '$first_name'       => user_details_hash['first_name'],
            '$last_name'        => user_details_hash['last_name'],
            '$email'            => user_details_hash['email'],
            #'$country'          => self.country.try(:name),
            'user_group'        => user_details_hash['user_group_name'],
            'subscription_plan' => user_details_hash['subscription_plan_name'],
            'guid'              => user_details_hash['guid']
    })
    Rails.logger.debug "DEBUG: User#create_on_mixpanel created a user. Tracker:#{tracker.inspect}."
  end

end
