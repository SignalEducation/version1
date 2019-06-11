class ChangeCurrentStatusToStripeStatusOrders < ActiveRecord::Migration[4.2]
  def change
    rename_column :orders, :current_status, :stripe_status
  end
end
