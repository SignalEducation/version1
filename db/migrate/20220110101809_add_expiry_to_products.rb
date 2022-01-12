class AddExpiryToProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :months_to_expiry, :integer, default: nil
  end
end
