class StripeApiProcessorWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'medium'

  def perform(stripe_event_id, api_version, account_url = "")
    StripeApiEvent.create!(guid: stripe_event_id, api_version: api_version,
                           account_url: account_url)
  rescue ActiveModel::ValidationError, ActiveRecord::RecordInvalid => e
    Rails.logger.error "StripeApiEvent#existing_guid #{e.model.errors.inspect}"
  end
end
