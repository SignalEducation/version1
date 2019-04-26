class AddImagePaperclipAttributesToBlogPost < ActiveRecord::Migration[4.2]
  def up
    add_attachment :blog_posts, :image
  end

  def down
    remove_attachment :blog_posts, :image
  end

end
