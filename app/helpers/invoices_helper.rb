# frozen_string_literal: true

module InvoicesHelper
  def invoice_type(invoice)
    subscription?(invoice) ? 'Subscription' : 'Order'
  end

  def pdf_description(invoice, item)
    return 'Prorated Discount' if item.prorated.present?

    if subscription?(invoice)
      I18n.t("views.general.subscription_in_months.a#{invoice.subscription.subscription_plan.payment_frequency_in_months}")
    elsif invoice.order.product.mock_exam?
      invoice.order.product.mock_exam.name.to_s.truncate(20)
    elsif invoice.order.product.cbe?
      invoice.order.product.cbe.name.to_s.truncate(20)
    end
  end

  def item_vat_rate(vat_rate, item)
    item.prorated ? '' : vat_rate
  end

  private

  def subscription?(invoice)
    invoice.subscription_id.present?
  end
end
