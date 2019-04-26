class AddSkuGuidToProducts < ActiveRecord::Migration[4.2]
  def change
    add_column :products, :stripe_sku_guid, :string, index: true
  end
end
