class AddMarketingAttributesToHomePages < ActiveRecord::Migration[5.2]
  def change
    rename_column :home_pages, :form_section, :registration_form
    add_column :home_pages, :login_form, :boolean, default: false, null: false
    add_column :home_pages, :preferred_payment_frequency, :integer
    add_column :home_pages, :header_h1, :string
    add_column :home_pages, :header_paragraph, :string
    add_column :home_pages, :registration_form_heading, :string
    add_column :home_pages, :login_form_heading, :string
  end
end
