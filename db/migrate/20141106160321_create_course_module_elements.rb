class CreateCourseModuleElements < ActiveRecord::Migration
  def change
    create_table :course_module_elements do |t|
      t.string :name
      t.string :name_url, index: true
      t.text :description
      t.integer :estimated_time_in_seconds
      t.integer :course_module_id, index: true
      t.integer :course_video_id, index: true
      t.integer :course_quiz_id, index: true
      t.integer :sorting_order
      t.integer :forum_topic_id, index: true
      t.integer :tutor_id, index: true
      t.integer :related_quiz_id, index: true
      t.integer :related_video_id, index: true

      t.timestamps
    end
  end
end
