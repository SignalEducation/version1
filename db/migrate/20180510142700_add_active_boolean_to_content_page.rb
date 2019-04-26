class AddActiveBooleanToContentPage < ActiveRecord::Migration[4.2]
  def change
    add_column :content_pages, :active, :boolean, default: false, index: true
  end
end
