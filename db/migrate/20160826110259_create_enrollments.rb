class CreateEnrollments < ActiveRecord::Migration
  def change
    create_table :enrollments do |t|
      t.integer :user_id
      t.integer :subject_course_id
      t.integer :subject_course_user_log_id

      t.timestamps null: false
    end
  end
end
