class IntercomUpgradePageLoadedEventWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'low'

  def perform(user_id, country_name)
    user = User.where(id: user_id).first
    if user
      intercom = Intercom::Client.new(
          app_id: ENV['intercom_app_id'],
          api_key: ENV['intercom_api_key']
      )

      intercom.events.create(
          :event_name => 'Upgrade Page Load',
          :created_at => Time.now.to_i,
          :user_id => user_id,
          :email => user.email,
          :metadata => {
              "Ip Country" => country_name
          }

      )
    end
  end

end
