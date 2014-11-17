class CreateForumTopicUsers < ActiveRecord::Migration
  def change
    create_table :forum_topic_users do |t|
      t.integer :user_id, index: true
      t.integer :forum_topic_id, index: true

      t.timestamps
    end
  end
end
