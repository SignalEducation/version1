class AddFooterLinkBooleanToHomePages < ActiveRecord::Migration
  def change
    add_column :home_pages, :footer_link, :boolean, default: false
  end
end
