class PaypalWebhookReprocessWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'medium'

  def perform(webhook_id)
    webhook = PaypalWebhook.find(webhook_id)
    PaypalWebhookService.new.reprocess_webhook(webhook)
  end
end
