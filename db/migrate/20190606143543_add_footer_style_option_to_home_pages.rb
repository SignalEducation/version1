class AddFooterStyleOptionToHomePages < ActiveRecord::Migration[5.2]
  def change
    add_column :home_pages, :footer_option, :string, default: 'white'
  end
end
