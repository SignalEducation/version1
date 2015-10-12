class AddGroupIdToCorporateGroupGrants < ActiveRecord::Migration
  def change
    add_column :corporate_group_grants, :group_id, :integer, index: true
  end
end
