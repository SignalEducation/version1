class RemoveStaticPageModels < ActiveRecord::Migration
  def change
    drop_table :static_page_uploads
    drop_table :static_pages
  end
end
