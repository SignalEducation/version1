require 'paypal-sdk-rest'

class PaypalWebhooksService
  include PayPal::SDK::REST
  include PayPal::SDK::Core::Logging

  def initialize(request, paypal_body)
    @request = request
    @paypal_body = paypal_body
    @webhook = nil
  end

  def process
    Rails.logger.info "WEBHOOK: Processing"
    trigger_payment_actions
  end

  def record_webhook
    Rails.logger.info "WEBHOOK: Recording"
    @webhook = PaypalWebhook.create(
      guid: @paypal_body['id'], 
      event_type: @paypal_body['event_type'], 
      payload: @paypal_body
    )
  end

  def valid?
    webhook_id = "0UT24471LT528120V"

    WebhookEvent.verify(
      transmission_id,
      timestamp,
      webhook_id,
      @paypal_body,
      cert_url,
      actual_signature,
      auth_algo
    )
  end

  private

  def trigger_payment_actions
    case @webhook.event_type
    when 'BILLING.SUBSCRIPTION.CREATED'

      Rails.logger.info "WEBHOOK: TRIGGERED SUBSCRIPTION.CREATED ACTION"
      # do stuff
    when 'BILLING.SUBSCRIPTION.CANCELLED'
      @webhook.process_subscription_cancelled
    when 'BILLING.SUBSCRIPTION.RE-ACTIVATED'
      # do stuff
    when 'BILLING.SUBSCRIPTION.SUSPENDED'
      # do stuff
    when 'BILLING.SUBSCRIPTION.UPDATED'
      # do stuff
    when 'PAYMENT.SALE.COMPLETED'
      @webhook.process_sale_completed
    when 'PAYMENT.SALE.DENIED'
      @webhook.process_sale_denied
    end
  end

  def transmission_id
    @request.headers["Paypal-Transmission-Id"]
  end

  def actual_signature
    @request.headers["Paypal-Transmission-Sig"]
  end

  def auth_algo
    @request.headers["Paypal-Auth-Algo"].sub(/withRSA/i, "")
  end

  def cert_url
    @request.headers["Paypal-Cert-Url"]
  end

  def timestamp
    @request.headers["Paypal-Transmission-Time"]
  end
end
