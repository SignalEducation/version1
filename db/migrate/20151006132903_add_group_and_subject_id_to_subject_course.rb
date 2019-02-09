class AddGroupAndSubjectIdToSubjectCourse < ActiveRecord::Migration[4.2]
  def change
    add_column :subject_courses, :group_id, :integer
    add_column :subject_courses, :subject_id, :integer
  end
end
