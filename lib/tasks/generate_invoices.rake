# frozen_string_literal: true

namespace :invoices do
  desc 'sorting out the dodgy paypal webhook payloads'
  task generate_order_invoices: :environment do
    orders               = Order.includes(:invoice).where(invoices: { order_id: nil })
    orders_not_processed = []

    puts 'Updating orders...'
    orders.find_in_batches(batch_size: 1000) do |orders_group|
      Order.transaction do
        orders_group.each do |order|
          puts '================'
          order.generate_invoice
          order.save
          puts "Order #{order.id} updated....."
        rescue ActiveRecord::ActiveRecordError => e
          puts "update error in order #{order.id}"
          puts e.message
          orders_not_processed << order.id
        end
      end
    end

    puts "Attention, these orders didn't create invoices: #{orders_not_processed}!!!" if orders_not_processed.present?
  end
end
