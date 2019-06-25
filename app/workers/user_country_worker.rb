class UserCountryWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'medium'

  def perform(user_id, ip_address)
    user = User.find(user_id)
    user_country = IpAddress.get_country(request.remote_ip)
    if user_country && user.country_id != user_country.id
      user.update!(country_id: user_country.id)
    end
  end
end
