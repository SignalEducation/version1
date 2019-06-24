class AddVideoGuidToHomePages < ActiveRecord::Migration[5.2]
  def change
    add_column :home_pages, :video_guid, :string, index: true
  end
end
