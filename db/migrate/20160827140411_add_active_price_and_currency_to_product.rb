class AddActivePriceAndCurrencyToProduct < ActiveRecord::Migration[4.2]
  def change
    add_column :products, :active, :boolean, default: false, index: true
    add_column :products, :currency_id, :integer, index: true
    add_column :products, :price, :decimal
  end
end
