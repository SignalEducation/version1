class CreateForumTopics < ActiveRecord::Migration
  def change
    create_table :forum_topics do |t|
      t.integer :forum_topic_id, index: true
      t.integer :course_module_element_id, index: true
      t.string :heading
      t.text :description
      t.boolean :active, default: true, null: false
      t.datetime :publish_from
      t.datetime :publish_until
      t.integer :reviewed_by, index: true

      t.timestamps
    end
  end
end
