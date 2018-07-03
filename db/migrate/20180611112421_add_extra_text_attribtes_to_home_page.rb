class AddExtraTextAttribtesToHomePage < ActiveRecord::Migration
  def change
    add_column :home_pages, :header_button_link, :string
    add_column :home_pages, :header_button_subtext, :string
  end
end
