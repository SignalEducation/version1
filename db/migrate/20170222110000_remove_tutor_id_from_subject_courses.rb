class RemoveTutorIdFromSubjectCourses < ActiveRecord::Migration
  def change
    remove_column :subject_courses, :tutor_id
  end
end
