class AddSubjectCourseCategoryIdToSubjectCourse < ActiveRecord::Migration

  def up
    add_column :subject_courses, :subject_course_category_id, :integer, index: true
    unless Rails.env.test?
      SubjectCourse.find_each do |course|
        course.subject_course_category_id = 1
        course.save!
      end
    end
  end

  def down
    remove_column :subject_courses, :subject_course_category_id, :integer, index: true
  end

end
