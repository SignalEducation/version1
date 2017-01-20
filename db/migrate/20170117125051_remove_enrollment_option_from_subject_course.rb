class RemoveEnrollmentOptionFromSubjectCourse < ActiveRecord::Migration
  def change
    remove_column :subject_courses, :enrollment_option
  end
end
