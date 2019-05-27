class AddParentIdsToExternalBannerModel < ActiveRecord::Migration[4.2]
  def change
    add_column :external_banners, :home_page_id, :integer, index: true
    add_column :external_banners, :content_page_id, :integer, index: true
  end
end
