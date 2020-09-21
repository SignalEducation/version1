class AddSavingsLabelToProduct < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :savings_label, :string
  end
end
