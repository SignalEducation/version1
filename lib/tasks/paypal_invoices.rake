# frozen_string_literal: true

namespace :paypal do
  desc 'Fix up the badly user_id sets'
  task fix_invoices_user_id: :environment do
    Rails.logger = Logger.new(Rails.root.join('log/tasks.log'))
    Rails.logger.info 'Running command to fix up bad bad user_id in invoices...'

    total_time = Benchmark.measure do
      invoices = Invoice.where(user_id: 72160)
      # invoices = [Invoice.last]
      Rails.logger.info "============= Total Records #{invoices.count} =============="

      invoices.each do |invoice|
        Rails.logger.info "Starting Invoice ##{invoice.id}..."

        sale = PayPal::SDK::REST::Sale.find(invoice.paypal_payment_guid)
        order = Order.find_by(paypal_guid: sale.parent_payment)

        Rails.logger.info "Updating  ##{invoice.id} Invoice user_id from #{invoice.user_id} to #{order.user_id}"
        Rails.logger.info "Paypal Sale: #{invoice.paypal_payment_guid}"
        Rails.logger.info "Paypal Payment: #{order.paypal_guid}"

        invoice.update(subscription_id: nil, user_id: order.user_id)

        Rails.logger.info "Invoice ##{invoice.id} successfully updated."
      rescue => e
        Rails.logger.error "Invoice ##{invoice.id} not updated"
        Rails.logger.error "Error: #{e.message}"
      end
    end
    Rails.logger.info "============= Total time #{total_time.real} =============="
    Rails.logger.info '=========================================================='
  end
end
