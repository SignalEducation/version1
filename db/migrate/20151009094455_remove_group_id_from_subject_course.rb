class RemoveGroupIdFromSubjectCourse < ActiveRecord::Migration[4.2]
  def change
    remove_column :subject_courses, :group_id, :integer
    remove_column :subject_courses, :subject_id, :integer
  end
end
