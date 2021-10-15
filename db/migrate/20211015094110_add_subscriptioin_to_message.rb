class AddSubscriptioinToMessage < ActiveRecord::Migration[5.2]
  def change
    add_column :messages, :subscription_id, :integer, default: nil
    add_column :messages, :order_id, :integer, default: nil
  end
end
