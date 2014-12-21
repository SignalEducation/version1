class CreateStaticPageUploads < ActiveRecord::Migration
  def up
    create_table :static_page_uploads do |t|
      t.string :description
      t.integer :static_page_id, index: true

      t.timestamps
    end
    add_attachment :static_page_uploads, :upload
  end

  def down
    remove_attachment :static_page_uploads, :upload
    drop_table :static_page_uploads
  end
end
