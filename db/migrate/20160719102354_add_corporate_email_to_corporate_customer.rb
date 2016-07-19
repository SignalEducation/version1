class AddCorporateEmailToCorporateCustomer < ActiveRecord::Migration
  def change
    add_column :corporate_customers, :corporate_email, :string
  end
end
