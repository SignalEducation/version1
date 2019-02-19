class AddEnrollmentOptionToSubjectCourseModel < ActiveRecord::Migration[4.2]
  def change
    add_column :subject_courses, :enrollment_option, :boolean, default: false, index: true
  end
end
