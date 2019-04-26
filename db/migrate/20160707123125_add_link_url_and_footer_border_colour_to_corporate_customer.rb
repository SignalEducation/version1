class AddLinkUrlAndFooterBorderColourToCorporateCustomer < ActiveRecord::Migration[4.2]
  def change
    add_column :corporate_customers, :external_url, :string, default: nil
    add_column :corporate_customers, :footer_border_colour, :string, default: '#EFF3F6'
  end
end
