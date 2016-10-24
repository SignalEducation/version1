class AddEnrollmentOptionToSubjectCourseModel < ActiveRecord::Migration
  def change
    add_column :subject_courses, :enrollment_option, :boolean, default: false, index: true
  end
end
