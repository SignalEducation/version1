class AddSubjectCourseCategoryIdToSubjectCourse < ActiveRecord::Migration
  def change
    add_column :subject_courses, :subject_course_category_id, :integer, index: true
  end
end
