class StripeApiProcessorWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'medium'

  def perform(stripe_event_id, api_version)
    event = StripeApiEvent.new(guid: stripe_event_id, api_version: api_version)
    event.get_data_from_stripe
    event.save! # will keep the job in the queue if event fails to save for some reason
  end

end
