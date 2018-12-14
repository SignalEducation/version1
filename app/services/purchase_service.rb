class PurchaseService
  attr_reader :order

  def initialize(order)
    @order = order
  end

  def complete_purchase(params)
    if self.stripe?
      @order = StripeService.new.complete_purchase(@order, params[:order][:stripe_token])
    elsif self.paypal?
      @order.save!
      @order = PaypalService.new.complete_purchase(@order)
    end
  end

  def paypal?
    (@order.use_paypal.present? && @order.use_paypal == 'true') || @order.paypal_token.present?
  end

  def stripe?
    @order.stripe_token.present? || @order.stripe_guid.present?
  end
end