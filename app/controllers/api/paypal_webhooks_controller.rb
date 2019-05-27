class Api::PaypalWebhooksController < Api::BaseController
  protect_from_forgery except: :create

  def create
    @hook_service = PaypalWebhookService.new
    if @hook_service.record_webhook(params.to_unsafe_h)
      @hook_service.process_webhook
      render body: nil, status: 204
    else
      Rails.logger.error "ERROR: Api/Paypal#Create: Unable to save PayPal webhook: #{@hook_service.webhook.errors.full_messages.join(' | ')}"
      render body: nil, status: 404
    end
  rescue => e
    Rails.logger.error "ERROR: Api/Paypal#Create: Exception: Unable to process PayPal webhook: #{e.inspect}"
    render body: nil, status: 404
  end
end
