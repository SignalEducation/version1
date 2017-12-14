class AddNewBooleansToUserGroupModel < ActiveRecord::Migration
  def change
    add_column :user_groups, :system_requirements_access, :boolean, default: false, index: true
    add_column :user_groups, :content_management_access, :boolean, default: false, index: true
    add_column :user_groups, :stripe_management_access, :boolean, default: false, index: true
    add_column :user_groups, :user_management_access, :boolean, default: false, index: true
    add_column :user_groups, :developer_access, :boolean, default: false, index: true
    add_column :user_groups, :home_pages_access, :boolean, default: false, index: true
    add_column :user_groups, :user_group_management_access, :boolean, default: false, index: true
    add_column :user_groups, :student_user, :boolean, default: false, index: true
    add_column :user_groups, :trial_or_sub_required, :boolean, default: false, index: true
    add_column :user_groups, :blocked_user, :boolean, default: false, index: true
  end
end
