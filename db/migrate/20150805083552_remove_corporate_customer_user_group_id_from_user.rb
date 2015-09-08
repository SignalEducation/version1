class RemoveCorporateCustomerUserGroupIdFromUser < ActiveRecord::Migration
  def change
    remove_column :users, :corporate_customer_user_group_id, :integer
  end
end
