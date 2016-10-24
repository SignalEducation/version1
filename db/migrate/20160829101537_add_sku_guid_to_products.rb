class AddSkuGuidToProducts < ActiveRecord::Migration
  def change
    add_column :products, :stripe_sku_guid, :string, index: true
  end
end
