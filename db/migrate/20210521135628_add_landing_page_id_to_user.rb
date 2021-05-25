class AddLandingPageIdToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :home_page_id, :integer
  end
end
