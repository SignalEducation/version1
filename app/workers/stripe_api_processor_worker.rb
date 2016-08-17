class StripeApiProcessorWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'medium'

  def perform(stripe_event_id, api_version, account_url = "", invoice_url = "")
    StripeApiEvent.create!(guid: stripe_event_id, api_version: api_version, account_url: account_url, invoice_url: invoice_url)
  end

end
