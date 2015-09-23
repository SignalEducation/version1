class AddProfileFieldsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :first_description, :text
    add_column :users, :second_description, :text
    add_column :users, :wistia_url, :string
    add_column :users, :personal_url, :string
    add_column :users, :name_url, :string
  end
end
