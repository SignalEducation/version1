class AddSortingOrderToProducts < ActiveRecord::Migration[4.2]
  def change
    add_column :products, :sorting_order, :integer
  end
end
