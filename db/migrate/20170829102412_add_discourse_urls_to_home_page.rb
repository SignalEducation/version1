class AddDiscourseUrlsToHomePage < ActiveRecord::Migration
  def change
    add_column :home_pages, :discourse_ids, :string
  end
end
