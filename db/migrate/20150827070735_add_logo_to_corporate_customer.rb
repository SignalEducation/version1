class AddLogoToCorporateCustomer < ActiveRecord::Migration[4.2]
  def up
    add_attachment :corporate_customers, :logo
  end

  def down
    remove_attachment :corporate_customers, :logo
  end
end
