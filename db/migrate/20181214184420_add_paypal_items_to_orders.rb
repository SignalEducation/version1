class AddPaypalItemsToOrders < ActiveRecord::Migration[4.2]
  def change
    add_column :orders, :paypal_guid, :string
    add_column :orders, :paypal_status, :string
  end
end
