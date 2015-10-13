class CreateSubjectCourseUserLogs < ActiveRecord::Migration
  def change
    create_table :subject_course_user_logs do |t|
      t.integer :user_id, index: true
      t.string :session_guid, index: true
      t.integer :subject_course_id, index: true
      t.integer :percentage_complete, default: 0
      t.integer :count_of_cmes_completed, default: 0
      t.integer :latest_course_module_element_id
      t.boolean :completed, default: false

      t.timestamps null: false
    end
  end
end
