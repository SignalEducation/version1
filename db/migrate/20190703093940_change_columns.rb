class ChangeColumns < ActiveRecord::Migration[5.2]
  def change
    add_column :cbe_sections, :name, :string
    remove_column :cbe_sections, :cbe_section_id
  end
end
