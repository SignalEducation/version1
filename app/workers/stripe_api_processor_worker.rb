class StripeApiProcessorWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'medium'

  def perform(stripe_event_id, api_version)
    if api_version == 'v01'
      Api::StripeV01Controller.send(:deferred_process, stripe_event_id)
    end
  end

end
