# frozen_string_literal: true

namespace :invoices do
  desc 'Create invoices to old orders'
  task generate_order_invoices: :environment do
    orders               = Order.includes(:invoice).where(invoices: { order_id: nil })
    orders_not_processed = []

    Rails.logger = Logger.new(Rails.root.join('log', 'tasks.log'))
    Rails.logger.info 'Updating orders...'

    total_time = Benchmark.measure do
      orders.find_in_batches(batch_size: 1000) do |orders_group|
        batch_time = Benchmark.measure do
          Order.transaction do
            Rails.logger.info "======= #{orders_group.count} ORDERS ========="
            orders_group.each do |order|
              order.generate_invoice
              order.save
              Rails.logger.info "Order #{order.id} updated....."
            rescue ActiveRecord::ActiveRecordError => e
              Rails.logger.error "update error in order #{order.id}"
              Rails.logger.error e.message
              orders_not_processed << order.id
            end
          end
        end

        Rails.logger.info '============ Batch time execution ==============='
        Rails.logger.info batch_time.real
        Rails.logger.info '============ Batch time execution ==============='
      end

      Rails.logger.info '============ Total time execution ==============='
      Rails.logger.info total_time.real
      Rails.logger.info '============ Total time execution ==============='
    end
    Rails.logger.error "Attention, these orders didn't create invoices: #{orders_not_processed}!!!" if orders_not_processed.present?
  end
end
