class AddTabViewToGroup < ActiveRecord::Migration[5.2]
  def change
    add_column :groups, :tab_view, :boolean, default: false, null: false
  end
end
