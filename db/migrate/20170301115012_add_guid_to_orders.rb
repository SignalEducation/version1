class AddGuidToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :reference_guid, :string, index: true
  end
end
