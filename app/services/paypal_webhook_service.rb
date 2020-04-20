# frozen_string_literal: true

require 'paypal-sdk-rest'

class PaypalWebhookService
  include PayPal::SDK::REST
  include PayPal::SDK::Core::Logging

  attr_accessor :webhook

  def record_webhook(paypal_body)
    @webhook = PaypalWebhook.find_or_create_by(
      guid: paypal_body['id'],
      event_type: paypal_body['event_type'],
      payload: paypal_body
    )
    if @webhook.id
      @webhook
    else
      false
    end
  end

  def process_webhook
    trigger_payment_actions
  end

  def reprocess_webhook(webhook)
    @webhook = webhook
    event = PayPal::SDK::REST::WebhookEvent.get(@webhook.guid)
    @webhook.update_columns(payload: {})
    payload = JSON.parse(event.to_json)
    @webhook.update_columns(payload: payload)
    trigger_payment_actions
  rescue PayPal::SDK::Core::Exceptions::ResourceNotFound
    Rails.logger.info "Webhook information no longer available for PaypalWebhook #{@webhook.id}"
  end

  private

  def trigger_payment_actions
    case @webhook.event_type
    when 'BILLING.SUBSCRIPTION.CREATED'
      Rails.logger.info "PAYPAL WEBHOOK: TRIGGERED SUBSCRIPTION.CREATED ACTION"
    when 'BILLING.SUBSCRIPTION.CANCELLED'
      @webhook.process_subscription_cancelled
    when 'BILLING.SUBSCRIPTION.RE-ACTIVATED'
      # do stuff
    when 'BILLING.SUBSCRIPTION.SUSPENDED'
      @webhook.process_subscription_suspended
    when 'BILLING.SUBSCRIPTION.UPDATED'
      # do stuff
    when 'PAYMENT.SALE.COMPLETED'
      @webhook.process_sale_completed
    when 'PAYMENT.SALE.DENIED'
      @webhook.process_sale_denied
    end
  end
end
