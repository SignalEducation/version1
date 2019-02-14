class AddExtraTextAttribtesToHomePage < ActiveRecord::Migration[4.2]
  def change
    add_column :home_pages, :header_button_link, :string
    add_column :home_pages, :header_button_subtext, :string
  end
end
