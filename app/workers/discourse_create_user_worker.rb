class DiscourseCreateUserWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'low'

  def perform(name, email, password)
    conn = Faraday.new(:url => 'https://community.learnsignal.com') do |faraday|
      faraday.request  :url_encoded             # form-encode POST params
      faraday.response :logger                  # log requests to STDOUT
      faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
    end

    payload = { name: name, username: name, email: email, password: password, active: true, api_key: ENV['learnsignal_discourse_api_key'], api_username: ENV['learnsignal_discourse_api_username'] }

    conn.post '/users', payload

  end

end
