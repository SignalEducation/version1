class RemoveEnrollmentOptionFromSubjectCourse < ActiveRecord::Migration[4.2]
  def change
    remove_column :subject_courses, :enrollment_option
  end
end
