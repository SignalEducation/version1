class AddGroupAndSubjectIdToSubjectCourse < ActiveRecord::Migration
  def change
    add_column :subject_courses, :group_id, :integer
    add_column :subject_courses, :subject_id, :integer
  end
end
