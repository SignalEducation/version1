class AddGroupIdToCorporateGroupGrants < ActiveRecord::Migration[4.2]
  def change
    add_column :corporate_group_grants, :group_id, :integer, index: true
  end
end
