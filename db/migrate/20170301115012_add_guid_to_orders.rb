class AddGuidToOrders < ActiveRecord::Migration[4.2]
  def change
    add_column :orders, :reference_guid, :string, index: true
  end
end
