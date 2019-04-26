class AddProductTypeToProducts < ActiveRecord::Migration[4.2]
  def change
    add_column :products, :product_type, :integer, default: 0
  end
end
