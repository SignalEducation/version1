class AddBooleansToHomePages < ActiveRecord::Migration[5.2]
  def change
    add_column :home_pages, :usp_section, :boolean, default: true
  end
end
