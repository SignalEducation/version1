class DiscourseCreateUserWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'low'

  def perform(user_id, name, email, password)
    conn = Faraday.new(:url => 'https://community.learnsignal.com') do |faraday|
      faraday.request  :url_encoded             # form-encode POST params
      faraday.response :logger                  # log requests to STDOUT
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end

    payload = { name: name, username: name, email: email, password: password, api_key: ENV['learnsignal_discourse_api_key'], api_username: ENV['learnsignal_discourse_api_username'] }

    conn.post '/users', payload

    user = User.find(user_id)
    user.update_attribute(:discourse_user, true)

  end

end
