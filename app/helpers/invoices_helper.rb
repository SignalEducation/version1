# frozen_string_literal: true

module InvoicesHelper
  def invoice_type(invoice)
    subscription?(invoice) ? 'Subscription' : 'Order'
  end

  def pdf_description(invoice, item)
    return 'Prorated Discount' if item.prorated.present?

    if subscription?(invoice)
      "#{exam_body_name(invoice)} #{invoice.subscription.subscription_plan.interval_name} Subscription"
    elsif invoice.order.product.mock_exam?
      invoice.order.product.mock_exam.name.to_s.truncate(20)
    elsif invoice.order.product.cbe?
      invoice.order.product.cbe.name.to_s.truncate(20)
    elsif invoice.order.product.lifetime_access? || invoice.order.product.program_access?
      invoice.order.product.name.to_s.truncate(40)
    end
  end

  def item_vat_rate(vat_rate, item)
    item.prorated ? '' : vat_rate
  end

  private

  def subscription?(invoice)
    invoice.subscription_id.present?
  end

  def exam_body_name(invoice)
    subscription?(invoice) ? invoice.subscription.subscription_plan.exam_body : invoice.order.product.group.exam_body
  end
end
