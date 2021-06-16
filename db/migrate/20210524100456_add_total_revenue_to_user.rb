class AddTotalRevenueToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :subscriptions_revenue, :decimal, default: 0
    add_column :users, :orders_revenue, :decimal, default: 0
  end
end
