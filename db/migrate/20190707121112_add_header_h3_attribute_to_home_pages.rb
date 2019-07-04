class AddHeaderH3AttributeToHomePages < ActiveRecord::Migration[5.2]
  def change
    add_column :home_pages, :header_h3, :string
  end
end
