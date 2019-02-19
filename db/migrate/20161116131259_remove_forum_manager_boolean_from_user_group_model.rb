class RemoveForumManagerBooleanFromUserGroupModel < ActiveRecord::Migration[4.2]
  def change
    remove_column :user_groups, :forum_manager, :boolean
  end
end
