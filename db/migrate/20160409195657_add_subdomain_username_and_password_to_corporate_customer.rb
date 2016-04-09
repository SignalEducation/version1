class AddSubdomainUsernameAndPasswordToCorporateCustomer < ActiveRecord::Migration
  def change
    add_column :corporate_customers, :subdomian, :string, default: nil, index: true
    add_column :corporate_customers, :user_name, :string, default: nil, index: true
    add_column :corporate_customers, :passcode, :string, default: nil
  end
end
