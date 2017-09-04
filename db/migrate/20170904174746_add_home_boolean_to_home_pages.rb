class AddHomeBooleanToHomePages < ActiveRecord::Migration
  def change
    add_column :home_pages, :home, :boolean, default: false, index: true
  end
end
