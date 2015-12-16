class SubscriptionInvoice < Prawn::Document

  def initialize(invoice, view)
    super()
    @invoice = invoice
    @view = view
    sub = Subscription.find_by_id(@invoice.subscription_id)
    plan = SubscriptionPlan.find_by_id(sub.id)
    if plan.payment_frequency_in_months == 1
      @description = "LearnSignal Monthly Subscription"
    elsif plan.payment_frequency_in_months == 3
      @description = "LearnSignal Quaterly Subscription"
    elsif plan.payment_frequency_in_months == 12
      @description = "LearnSignal Yearly Subscription"
    else
    end
    currency = @invoice.currency
    @currency_symbol = currency.leading_symbol
    @status = @invoice.paid ? "Paid" : "Due"
    logo
    address
    invoice_id
    content
  end

  def logo
    move_down 10
    logopath =  "#{Rails.root}/app/assets/images/logo_withtext+thin.png"
    y_position = cursor
    image logopath, width: 275, height: 40, at: [125, y_position]
  end

  def address
    move_down 50
    font_size 12
    text "27 South Frederick Street, Dublin 2, Ireland", align: :center
  end

  def invoice_id
    move_down 85
    font_size 12
    text "Invoice ID:   #{@invoice.id}"
    move_down 10
    text "Bill to:      #{@invoice.user.full_name} - #{@invoice.user.try(:address)}"
  end

  def content
    move_down 25
    table([ ["Description", "Issued at", "Status", "Amount"],
            ["#{@description}", "#{@invoice.issued_at.utc.strftime('%d %b %y') }", "#{@status}", "#{@currency_symbol} #{@invoice.total}"],
            [" ", " ", " ", " "],
            [" ", " ", " ", " "],
            [ "Toatal Amount:  #{@currency_symbol} #{@invoice.total}"] ], width: 525, position: :center)
  end
end