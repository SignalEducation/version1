class AddForiehnKeysForSubjectCourse < ActiveRecord::Migration
  def change
    add_column :course_modules, :subject_course_id, :integer, index: true
    add_column :question_banks, :subject_course_id, :integer, index: true
    add_column :student_exam_tracks, :subject_course_id, :integer, index: true
    add_column :corporate_group_grants, :subject_course_id, :integer, index: true
  end
end
