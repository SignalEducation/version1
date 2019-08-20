# frozen_string_literal: true

class StripeService
  def create_customer!(user)
    customer = Stripe::Customer.create(email: user.email)
    user.update!(stripe_customer_id: customer.id)

    customer
  end

  def set_order_status(intent, order)
    if intent.status == 'requires_action' &&
       stripe_intent.next_action.type == 'use_stripe_sdk'
      order.state = 'pending_3d_secure'
    elsif intent.status != 'succeeded'
      order.state = 'errored'
    end
    order
  end

  def create_purchase(order)
    stripe_intent = create_payment_intent(order)
    order = set_order_status(stripe_intent, order)
    order.assign_attributes(stripe_customer_id: stripe_intent.customer,
                            stripe_payment_intent_id: stripe_intent.id,
                            stripe_client_secret: stripe_intent.client_secret)
    order
  rescue Stripe::CardError => e
    raise_payment_error(e.json_body[:error], __method__.to_s, :decline_reason)
  rescue => e
    raise_payment_error(e, __method__.to_s, :generic)
  end

  def confirm_purchase(order)
    intent = Stripe::PaymentIntent.confirm(order.stripe_payment_intent_id)
    unless intent.status == 'succeeded'
      raise_payment_error({}, __method__.to_s, :generic)
    end
  rescue Stripe::CardError => e
    raise_payment_error(e.json_body[:error], __method__.to_s, :decline_reason)
  end

  # PRODUCTS ===================================================================

  def create_product(product)
    stripe_product = create_stripe_product(product)
    stripe_sku = create_stripe_sku(product, stripe_product)

    product.update!(live_mode: stripe_product.livemode,
                    stripe_guid: stripe_product.id,
                    stripe_sku_guid: stripe_sku.id)
  end

  def update_product(product)
    stripe_product = Stripe::Product.retrieve(id: product.stripe_guid)
    stripe_product.name = product.name
    stripe_product.active = product.active
    stripe_product.save
  end

  # INVOICES ===================================================================

  def get_invoice(invoice_id)
    Stripe::Invoice.retrieve(id: invoice_id, expand: ['payment_intent'])
  end

  # PRIVATE ====================================================================

  private

  def create_payment_intent(order)
    Stripe::PaymentMethod.attach(order.stripe_payment_method_id,
                                 customer: order.user.stripe_customer_id)
    Stripe::PaymentIntent.create(
      payment_method: order.stripe_payment_method_id,
      customer: order.user.stripe_customer_id,
      amount: (order.product.price * 100).to_i,
      currency: order.product.currency.iso_code,
      confirmation_method: 'manual',
      confirm: true
    )
  end

  def create_stripe_product(product)
    Stripe::Product.create(name: product.name, shippable: false,
                           active: product.active, type: 'good')
  end

  def create_stripe_sku(product, stripe_product)
    Stripe::SKU.create(product: stripe_product.id,
                       currency: product.currency.iso_code,
                       price: (product.price.to_f * 100).to_i,
                       inventory: { type: 'infinite' })
  end

  def raise_payment_error(err, method, type)
    Rails.logger.error "StripeService##{method} - #{err.inspect}"
    raise Learnsignal::PaymentError, return_message(err, type)
  end

  def raise_subscription_error(err, method, type, msg = '')
    Rails.logger.error "StripeService##{method} - #{err.inspect}"
    raise Learnsignal::SubscriptionError, return_message(err, type, msg)
  end

  def return_message(e, type, msg = '')
    case type
    when :decline then "Your request was declined because - #{e[:message]}"
    when :sub_cancellation
      'Sorry! There was an error cancelling the subscription.'
    when :sub_change
      I18n.t('models.subscriptions.upgrade_plan.processing_error_at_stripe')
    when :custom then msg
    else
      'Sorry Something went wrong! Please contact us for assistance.'
    end
  end
end
