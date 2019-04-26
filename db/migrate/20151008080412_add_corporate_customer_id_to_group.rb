class AddCorporateCustomerIdToGroup < ActiveRecord::Migration[4.2]
  def change
    add_column :groups, :corporate_customer_id, :integer
  end
end
