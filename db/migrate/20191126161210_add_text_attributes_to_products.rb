class AddTextAttributesToProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :payment_heading, :string
    add_column :products, :payment_subheading, :string
    add_column :products, :payment_description, :text
  end
end
