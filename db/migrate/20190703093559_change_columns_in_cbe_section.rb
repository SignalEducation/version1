class ChangeColumnsInCbeSection < ActiveRecord::Migration[5.2]
  def change
    remove_column :cbe_sections, :cbes_id
    remove_column :cbe_sections, :name
  end
end
