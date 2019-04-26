class AddSubdomainUsernameAndPasswordToCorporateCustomer < ActiveRecord::Migration[4.2]
  def change
    add_column :corporate_customers, :subdomain, :string, default: nil, index: true
    add_column :corporate_customers, :user_name, :string, default: nil, index: true
    add_column :corporate_customers, :passcode, :string, default: nil
  end
end
