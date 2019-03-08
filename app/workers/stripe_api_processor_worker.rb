class StripeApiProcessorWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'medium'

  def perform(stripe_event_id, api_version, account_url = "")
    StripeApiEvent.find_or_create_by!(guid: stripe_event_id, api_version: api_version, account_url: account_url)
  end
end
