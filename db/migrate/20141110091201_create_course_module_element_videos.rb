class CreateCourseModuleElementVideos < ActiveRecord::Migration
  def change
    create_table :course_module_element_videos do |t|
      t.integer :course_module_element_id, index: true
      t.integer :raw_video_file_id, index: true
      t.string :name
      t.integer :run_time_in_seconds
      t.integer :tutor_id, index: true
      t.text :description
      t.string :tags
      t.string :difficulty_level
      t.integer :estimated_study_time_seconds
      t.text :transcript

      t.timestamps
    end
  end
end
