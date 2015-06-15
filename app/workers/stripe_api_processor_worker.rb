class StripeApiProcessorWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'medium'

  def perform(stripe_event_id, api_version, profile_url = "")
    StripeApiEvent.create!(guid: stripe_event_id, api_version: api_version, profile_url: profile_url)
  end

end
