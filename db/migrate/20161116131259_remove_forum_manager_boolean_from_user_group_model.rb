class RemoveForumManagerBooleanFromUserGroupModel < ActiveRecord::Migration
  def change
    remove_column :user_groups, :forum_manager, :boolean
  end
end
