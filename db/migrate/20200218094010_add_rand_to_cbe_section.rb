class AddRandToCbeSection < ActiveRecord::Migration[5.2]
  def change
    add_column :cbe_sections, :random, :boolean, default: false
  end
end
