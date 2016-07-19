class AddExternalLogoBoleanToCorporateCustomer < ActiveRecord::Migration
  def change
    add_column :corporate_customers, :external_logo_link, :boolean, default: false, index: true
  end
end
