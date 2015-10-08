class AddCorporateCustomerIdToGroup < ActiveRecord::Migration
  def change
    add_column :groups, :corporate_customer_id, :integer
  end
end
