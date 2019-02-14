class AddNameAndGroupIdToHomePage < ActiveRecord::Migration[4.2]
  def change
    add_column :home_pages, :group_id, :integer, index: true
    add_column :home_pages, :name, :string
  end
end
