# frozen_string_literal: true

class UserCountryWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'medium'

  def perform(user_id, ip_address)
    user = User.find(user_id)
    user_country = IpAddress.get_country(ip_address)
    return unless user_country && user.country_id != user_country.id

    user.update!(country_id: user_country.id)
  end
end
