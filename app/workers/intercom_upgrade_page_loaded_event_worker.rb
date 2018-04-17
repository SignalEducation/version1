class IntercomUpgradePageLoadedEventWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'low'

  def perform(user_id, country_name)
    IntercomNewSubscriptionLoadService.new({user_id: user_id, country_name: country_name}).perform
  end

end
