class AddLogoToCorporateCustomer < ActiveRecord::Migration
  def up
    add_attachment :corporate_customers, :logo
  end

  def down
    remove_attachment :corporate_customers, :logo
  end
end
