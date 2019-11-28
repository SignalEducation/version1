class AddGroupIdToProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :group_id, :integer
  end
end
