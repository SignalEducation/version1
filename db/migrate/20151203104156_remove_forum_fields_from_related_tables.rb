class RemoveForumFieldsFromRelatedTables < ActiveRecord::Migration[4.2]
  def change
    remove_column :course_module_elements, :forum_topic_id, :integer
    remove_column :user_notifications, :forum_topic_id, :integer
    remove_column :user_notifications, :forum_post_id, :integer
  end
end
