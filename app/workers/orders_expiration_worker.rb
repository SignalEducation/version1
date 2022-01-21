# frozen_string_literal: true

class OrdersExpirationWorker
  include Sidekiq::Worker

  sidekiq_options queue: :high

  def perform
    orders = valid_program_access_orders

    orders.each do |order|
      order.expire! if expire_order?(order.product)
    end
  end

  private

  def valid_program_access_orders
    Order.includes(:product).with_state(:completed).
      where(products: { product_type: :program_access }).
      where.not(products: { months_to_expiry: nil })
  end

  def expire_order?(order)
    # TODO(giordano) using day instead month to test cron job in staging env.
    # limit_date = order.created_at + order.product.months_to_expiry.month
    limit_date = order.created_at + order.product.months_to_expiry.day

    limit_date < Time.zone.today
  end
end
