require 'paypal-sdk-rest'

class PaypalService
  include Rails.application.routes.url_helpers
  include PayPal::SDK::REST

  # PAYMENTS ===================================================================

  def create_purchase(order)
    payment = Payment.new(payment_attributes(order))
    if payment.create
      order.assign_attributes(
        paypal_guid: payment.id,
        paypal_approval_url: payment.links.find{|v| v.rel == "approval_url" }.href,
        paypal_status: payment.state
      )
      order
    else
      Rails.logger.error "DEBUG: Order#create Failure to create PayPal Order - Error: #{payment.inspect}"
      raise Learnsignal::PaymentError.new('Sorry Something went wrong with PayPal! Please contact us for assistance.')
    end
  rescue PayPal::SDK::Core::Exceptions::ServerError => e
    Rails.logger.error "DEBUG: Order#create Failure to create Payment - PayPal Error - Error: #{e.message}"
    raise Learnsignal::PaymentError.new('PayPal seems to be having issues right now. Please try again in a few minutes. If this problem continues, contact us for assistance.')
  end

  def execute_payment(order, payment_id, payer_id)
    payment = Payment.find(order.paypal_guid)
    if payment_id == order.paypal_guid && payment.execute(payer_id: payer_id)
      order.update!(
        paypal_status: payment.state,
      )
      order.complete
    else
      order.record_error!
      Rails.logger.error "DEBUG: Order#create Failure to execute PayPal Payment for Order: ##{order.id} - Error: #{payment.inspect}"
      raise Learnsignal::PaymentError.new('Sorry! Something went wrong with PayPal. Please contact us for assistance.')
    end
  rescue PayPal::SDK::Core::Exceptions::ServerError => e
    Rails.logger.error "DEBUG: Order#execute Failure to execute Payment - PayPal Error - Error: #{e.message}"
    raise Learnsignal::PaymentError.new('PayPal seems to be having issues right now. Please try again in a few minutes. If this problem continues, contact us for assistance.')
  end

  private

  def payment_attributes(order)
    {
      intent: 'sale',
      payer: {
        payment_method: 'paypal'
      },
      redirect_urls: {
        return_url: execute_order_url(id: order.id, host: learnsignal_host, payment_processor: 'paypal'),
        cancel_url: new_order_url(product_id: order.product_id, host: learnsignal_host, flash: 'It seems you cancelled your order on Paypal. Still want to purchase?')
      },
      transactions: [
        {
          item_list: {
            items: [
              {
                name: order.product.name,
                price: order.product.price.to_s,
                currency: order.product.currency.iso_code,
                quantity: 1 
              }
            ]
          },
          amount: {
            total: order.product.price.to_s,
            currency: order.product.currency.iso_code
          },
          description: "Mock exam purchase - #{order.product.name}" 
        }
      ]
    }
  end

  def learnsignal_host
    Rails.env.production? ? 'https://learnsignal.com' : 'https://staging.learnsignal.com'
  end
end
