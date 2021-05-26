class AddTotalRevenueToSubscription < ActiveRecord::Migration[5.2]
  def change
    add_column :subscriptions, :total_revenue, :decimal, default: 0
  end
end
