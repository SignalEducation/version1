class RemoveTutorIdFromSubjectCourses < ActiveRecord::Migration[4.2]
  def change
    remove_column :subject_courses, :tutor_id
  end
end
