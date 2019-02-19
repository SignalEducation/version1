class AddStateToOrders < ActiveRecord::Migration[4.2]
  def change
    add_column :orders, :state, :string
  end
end
