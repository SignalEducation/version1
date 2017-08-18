class CreateBlogPosts < ActiveRecord::Migration
  def change
    create_table :blog_posts do |t|
      t.integer :home_page_id, index: true
      t.integer :sorting_order
      t.string :title
      t.text :description
      t.string :url

      t.timestamps null: false
    end
  end
end
