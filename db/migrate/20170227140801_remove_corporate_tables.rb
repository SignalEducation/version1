class RemoveCorporateTables < ActiveRecord::Migration[4.2]
  def change
    drop_table :corporate_customers
    drop_table :corporate_groups
    drop_table :corporate_group_grants
    drop_table :corporate_groups_users
  end
end
