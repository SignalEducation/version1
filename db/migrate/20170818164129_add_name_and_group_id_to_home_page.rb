class AddNameAndGroupIdToHomePage < ActiveRecord::Migration
  def change
    add_column :home_pages, :group_id, :integer, index: true
    add_column :home_pages, :name, :string
  end
end
