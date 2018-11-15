require 'paypal-sdk-rest'

class PaypalWebhooksService
  include PayPal::SDK::REST
  include PayPal::SDK::Core::Logging
  PayPal::SDK::REST.set_config(
    mode: "sandbox",
    client_id: "AajN5CdCcVFuea3nyJXXwZnAdkTxvgcd1IKeTcQVufHKl09WLTlmD5UKU7efXgC_VcZjUDTLveZ29FAt",
    client_secret: "EPF0A4akXxhuDx3BFKQGcEuYZw4_5sS13of5hX9MnjtvAVy1WmcPTj0cBk9lGxJ3TNqroDCTMC6PnaZc"
  )

  def initialize(request, paypal_body)
    @request = request
    @paypal_body = paypal_body
    @webhook = nil
  end
  # BILLING.PLAN.CREATED  A billing plan is created.  Create billing plan
  # BILLING.PLAN.UPDATED  A billing plan is updated.  Update billing plan
  # BILLING.SUBSCRIPTION.CANCELLED  A billing agreement is canceled.  Cancel agreement
  # BILLING.SUBSCRIPTION.CREATED  A billing agreement is created. Create agreement
  # BILLING.SUBSCRIPTION.RE-ACTIVATED A billing agreement is re-activated.  Re-activate agreement
  # BILLING.SUBSCRIPTION.SUSPENDED  A billing agreement is suspended. Suspend agreement
  # BILLING.SUBSCRIPTION.UPDATED

  # FOR NOW, THE ONLY ONES THAT WE NEED TO KNOW ABOUT ARE BILLING.SUBSCRIPTION.CANCELLED
  # AND BILLING.SUBSCRIPTION.SUSPENDED

  # FOR GENERAL PAYMENTS, PAYMENT.SALE.COMPLETED AND PAYMENT.SALE.DENIED LET US
  # KNOW OF SUCCESSFULL AND FAILED RECURRING PAYMENTS. WE CAN USE THESE TO GENERATE
  # INVOICES AND UPDATE THE SUBSCRIPTION OBJECT'S STATE AND NEXT BILLING DATE, ETC...
  # IF A SUBSCRIPTION NEEDS TO BE CANCELLED OR MARKED 'ERRORED', THEN THIS IS WHERE
  # WE'LL DO IT

  def process
    record_webhook
    trigger_payment_actions
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

  def record_webhook
    @webhook = PaypalWebhook.create!(
      guid: @paypal_body['id'], 
      event_type: @paypal_body['event_type'], 
      payload: @paypal_body
    )
  end

  def trigger_payment_actions
    case @webhook.event_type
    when 'BILLING.SUBSCRIPTION.CREATED'
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
