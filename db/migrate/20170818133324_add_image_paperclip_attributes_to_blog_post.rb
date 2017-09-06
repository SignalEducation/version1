class AddImagePaperclipAttributesToBlogPost < ActiveRecord::Migration
  def up
    add_attachment :blog_posts, :image
  end

  def down
    remove_attachment :blog_posts, :image
  end

end
