class AddPricingAndSignupBooleansToHomepages < ActiveRecord::Migration[5.2]
  def change
    add_column :home_pages, :form_section, :boolean, null: false, default: false
    add_column :home_pages, :pricing_section, :boolean, null: false, default: false
  end
end
