class AddSeoFieldsToGroup < ActiveRecord::Migration[5.2]
  def change
    add_column :groups, :seo_title, :string
    add_column :groups, :seo_description, :string
  end
end
