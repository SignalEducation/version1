class PurchaseService
  attr_reader :order

  def initialize(order)
    @order = order
  end

  def create_purchase
    if stripe?
      StripeService.new.create_purchase(order)
    elsif paypal?
      order.save!
      PaypalService.new.create_purchase(order)
    end
    order
  end

  def paypal?
    (order.use_paypal.present? && order.use_paypal == 'true') || order.paypal_guid.present?
  end

  def stripe?
    order.stripe_payment_method_id.present? || order.stripe_guid.present?
  end
end
