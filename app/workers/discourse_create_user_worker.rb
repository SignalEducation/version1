class DiscourseCreateUserWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'low'

  def perform(user_id, email)
    conn = Faraday.new(:url => 'https://community.learnsignal.com') do |faraday|
      faraday.request  :url_encoded             # form-encode POST params
      faraday.response :logger                  # log requests to STDOUT
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end

    payload = { email: email, api_key: ENV['LEARNSIGNAL_DISCOURSE_API_KEY'], api_username: ENV['LEARNSIGNAL_DISCOURSE_API_USERNAME'] }

    response = conn.post '/invites', payload

    if response.status == 200
      user = User.find(user_id)
      user.update_attribute(:discourse_user, true)
    else
      Rails.logger.error("ERROR: Discourse API- API invite post failed with status #{response.status}. Details: #{response}")
    end

  end

end
