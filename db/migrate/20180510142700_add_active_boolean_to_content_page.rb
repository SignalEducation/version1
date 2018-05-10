class AddActiveBooleanToContentPage < ActiveRecord::Migration
  def change
    add_column :content_pages, :active, :boolean, default: false, index: true
  end
end
