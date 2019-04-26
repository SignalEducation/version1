class AddGroupIdAndSubjectCourseIdToHomePages < ActiveRecord::Migration[4.2]
  def change
    add_column :home_pages, :group_id, :integer, index: true
    add_column :home_pages, :subject_course_id, :integer, index: true
  end
end
