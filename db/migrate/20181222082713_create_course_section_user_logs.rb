class CreateCourseSectionUserLogs < ActiveRecord::Migration[4.2]
  def change
    create_table :course_section_user_logs do |t|
      t.integer :user_id, index: true
      t.integer :course_section_id, index: true
      t.integer :subject_course_user_log_id, index: true
      t.integer :latest_course_module_element_id
      t.float :percentage_complete
      t.integer :count_of_cmes_completed
      t.integer :count_of_quizzes_taken
      t.integer :count_of_videos_taken

      t.timestamps null: false
    end
  end
end
