class FixCbeIntroductionPageAssociations < ActiveRecord::Migration[5.2]
  def change
    rename_column :cbe_introduction_pages, :number, :sorting_order
    remove_column :cbe_introduction_pages, :cbe_introduction_page_id
    add_reference :cbe_introduction_pages, :cbe, index: true
  end
end
