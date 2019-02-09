class AddCreatedByToForumTopics < ActiveRecord::Migration[4.2]
  def change
    add_column :forum_topics, :created_by, :integer, index: true
  end
end
