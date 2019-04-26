class RemoveSubjectCourseCategoryIdFromSubjectCourse < ActiveRecord::Migration[4.2]
  def change
    remove_column :subject_courses, :subject_course_category_id, :integer
  end
end
