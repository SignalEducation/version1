class RemoveSubjectCourseCategoryIdFromSubjectCourse < ActiveRecord::Migration
  def change
    remove_column :subject_courses, :subject_course_category_id, :integer
  end
end
