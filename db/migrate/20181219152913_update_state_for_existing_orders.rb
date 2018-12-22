class UpdateStateForExistingOrders < ActiveRecord::Migration
  def change
    Order.find_each do |order|
      case order.stripe_status
      when 'created'
        order.update_columns(state: 'pending')
      when 'paid'
        order.update_columns(state: 'completed')
      else
        order.update_columns(state: 'pending')
      end
    end
  end
end
