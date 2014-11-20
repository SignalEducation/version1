class CreateForumPosts < ActiveRecord::Migration
  def change
    create_table :forum_posts do |t|
      t.integer :user_id, index: true
      t.text :content
      t.integer :forum_topic_id, index: true
      t.boolean :blocked, default: false, null: false
      t.integer :response_to_forum_post_id, index: true

      t.timestamps
    end
  end
end
