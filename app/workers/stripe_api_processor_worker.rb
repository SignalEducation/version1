class StripeApiProcessorWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'medium'

  def perform(stripe_event_id, api_version)
    StripeApiEvent.create!(guid: stripe_event_id, api_version: api_version)
  end

end
