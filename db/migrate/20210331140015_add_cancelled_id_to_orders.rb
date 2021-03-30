class AddCancelledIdToOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :cancelled_by_id, :bigint
  end
end
