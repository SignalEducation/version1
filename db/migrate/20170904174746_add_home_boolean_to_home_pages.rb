class AddHomeBooleanToHomePages < ActiveRecord::Migration[4.2]
  def change
    add_column :home_pages, :home, :boolean, default: false, index: true
  end
end
