class AddContentAttributesToHomePage < ActiveRecord::Migration
  def change
    add_column :home_pages, :header_heading, :string
    add_column :home_pages, :header_paragraph, :text
    add_column :home_pages, :header_button_text, :string
  end
end
