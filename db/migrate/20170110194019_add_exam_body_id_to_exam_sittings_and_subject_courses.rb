class AddExamBodyIdToExamSittingsAndSubjectCourses < ActiveRecord::Migration
  def change
    add_column :exam_sittings, :exam_body_id, :integer, index: true
    add_column :subject_courses, :exam_body_id, :integer, index: true
  end
end
