class RemoveOldTutorAttributesFromUser < ActiveRecord::Migration
  def change
    remove_column :users, :first_description, :text
    remove_column :users, :second_description, :text
    remove_column :users, :wistia_url, :text
    remove_column :users, :personal_url, :text
    remove_column :users, :qualifications, :text
    remove_column :users, :phone_number, :string
  end
end
