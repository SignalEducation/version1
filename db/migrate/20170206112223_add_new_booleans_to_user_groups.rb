class AddNewBooleansToUserGroups < ActiveRecord::Migration
  def change
    add_column :user_groups, :customer_support, :boolean, default: false
    add_column :user_groups, :marketing_support, :boolean, default: false
  end
end
