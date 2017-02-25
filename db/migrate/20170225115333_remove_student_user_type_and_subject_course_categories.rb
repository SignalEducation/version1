class RemoveStudentUserTypeAndSubjectCourseCategories < ActiveRecord::Migration
  def change
    drop_table :student_user_types
    drop_table :subject_course_categories
  end
end
