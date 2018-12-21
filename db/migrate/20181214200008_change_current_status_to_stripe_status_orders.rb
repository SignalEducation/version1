class ChangeCurrentStatusToStripeStatusOrders < ActiveRecord::Migration
  def change
    rename_column :orders, :current_status, :stripe_status
  end
end
