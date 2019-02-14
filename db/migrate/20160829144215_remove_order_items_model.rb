class RemoveOrderItemsModel < ActiveRecord::Migration[4.2]
  def change
    drop_table :order_items
  end
end
