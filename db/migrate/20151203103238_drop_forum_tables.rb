class DropForumTables < ActiveRecord::Migration
  def change
    drop_table :forum_topic_users
    drop_table :forum_topics
    drop_table :forum_post_concerns
    drop_table :forum_posts
  end
end
