class AddDiscourseUrlsToHomePage < ActiveRecord::Migration[4.2]
  def change
    add_column :home_pages, :discourse_ids, :string
  end
end
