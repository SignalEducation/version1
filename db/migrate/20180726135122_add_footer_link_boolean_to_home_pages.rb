class AddFooterLinkBooleanToHomePages < ActiveRecord::Migration[4.2]
  def change
    add_column :home_pages, :footer_link, :boolean, default: false
  end
end
