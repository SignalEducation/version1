class AddExternalLogoBoleanToCorporateCustomer < ActiveRecord::Migration[4.2]
  def change
    add_column :corporate_customers, :external_logo_link, :boolean, default: false, index: true
  end
end
