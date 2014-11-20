class AddCreatedByToForumTopics < ActiveRecord::Migration
  def change
    add_column :forum_topics, :created_by, :integer, index: true
  end
end
