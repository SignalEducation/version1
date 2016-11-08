class CreateUserExamSittings < ActiveRecord::Migration
  def change
    create_table :user_exam_sittings do |t|
      t.integer :user_id, index: true
      t.integer :exam_sitting_id, index: true
      t.integer :subject_course_id, index: true
      t.date :date, index: true

      t.timestamps null: false
    end
  end
end
