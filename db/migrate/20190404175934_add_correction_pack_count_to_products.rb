class AddCorrectionPackCountToProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :correction_pack_count, :integer
  end
end
