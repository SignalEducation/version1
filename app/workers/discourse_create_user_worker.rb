class DiscourseCreateUserWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'low'

  def perform(email)
    conn = Faraday.new(:url => 'https://community.learnsignal.com') do |faraday|
      faraday.request  :url_encoded             # form-encode POST params
      faraday.response :logger                  # log requests to STDOUT
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end

    payload = { email: email, api_key: ENV['learnsignal_discourse_api_key'], api_username: ENV['learnsignal_discourse_api_username'] }

    response = conn.post '/invites', payload

    if response.status == 200
      user = User.where(email: email).last
      user.update_attribute(:discourse_user, true)
    end

  end

end
