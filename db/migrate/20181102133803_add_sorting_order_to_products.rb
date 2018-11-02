class AddSortingOrderToProducts < ActiveRecord::Migration
  def change
    add_column :products, :sorting_order, :integer
  end
end
