class RemoveOldUserGroupBooleans < ActiveRecord::Migration[4.2]
  def change
    remove_column :user_groups, :individual_student, :boolean, default: false, null: false
    remove_column :user_groups, :complimentary, :boolean, default: false, null: false
    remove_column :user_groups, :content_manager, :boolean, default: false, null: false
    remove_column :user_groups, :blogger, :boolean, default: false, null: false
    remove_column :user_groups, :customer_support, :boolean, default: false, null: false
    remove_column :user_groups, :marketing_support, :boolean, default: false, null: false
    remove_column :user_groups, :home_pages_access, :boolean, default: false

    add_column :user_groups, :marketing_resources_access, :boolean, default: false
  end
end
