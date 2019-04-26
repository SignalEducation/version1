class AddCorporateEmailToCorporateCustomer < ActiveRecord::Migration[4.2]
  def change
    add_column :corporate_customers, :corporate_email, :string
  end
end
