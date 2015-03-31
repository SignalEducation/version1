class MixpanelUserUpdateWorker
  include Sidekiq::Worker
  require 'mixpanel-ruby'

  sidekiq_options queue: 'high'

  def perform(user_id, first_name, last_name, email, user_group_name, subscription_plan_name, guid, user_country)
    tracker = Mixpanel::Tracker.new(ENV['mixpanel_key'])
    tracker.people.set(user_id, {
            '$first_name'       => first_name,
            '$last_name'        => last_name,
            '$email'            => email,
            #'$country'          => self.country.try(:name),
            'user_group'        => user_group_name,
            'subscription_plan' => subscription_plan_name,
            'guid'              => guid,
            '$country_code'     => user_country
    })
    Rails.logger.debug "DEBUG: User#create_on_mixpanel created a user. Tracker:#{tracker.inspect}."
  end

end
