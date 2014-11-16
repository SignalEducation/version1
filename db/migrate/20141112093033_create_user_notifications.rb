class CreateUserNotifications < ActiveRecord::Migration
  def change
    create_table :user_notifications do |t|
      t.integer :user_id, index: true
      t.string :subject_line
      t.text :content
      t.boolean :email_required, default: false, null: false
      t.datetime :email_sent_at
      t.boolean :unread, default: true, null: false
      t.datetime :destroyed_at
      t.string :message_type, index: true
      t.integer :forum_topic_id, index: true
      t.integer :forum_post_id, index: true
      t.integer :tutor_id, index: true
      t.boolean :falling_behind, deafult: false, null: false
      t.integer :blog_post_id, index: true

      t.timestamps
    end
  end
end
