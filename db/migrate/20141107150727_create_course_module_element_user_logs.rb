class CreateCourseModuleElementUserLogs < ActiveRecord::Migration
  def change
    create_table :course_module_element_user_logs do |t|
      t.integer :course_module_element_id
      t.integer :user_id, index: true
      t.string :session_guid
      t.boolean :element_completed, default: false, null: false
      t.integer :time_taken_in_seconds
      t.integer :quiz_score_actual
      t.integer :quiz_score_potential
      t.boolean :is_video, default: false, null: false
      t.boolean :is_quiz, default: false, null: false
      t.integer :course_module_id, index: true
      t.boolean :latest_attempt, default: true, null: false
      t.integer :corporate_customer_id

      t.timestamps
    end
    add_index :course_module_element_user_logs, :course_module_element_id, name: 'cme_user_logs_cme_id'
    add_index :course_module_element_user_logs, :corporate_customer_id, name: 'cme_user_logs_corporate_customer_id'
  end
end
