class AddGroupIdAndSubjectCourseIdToHomePages < ActiveRecord::Migration
  def change
    add_column :home_pages, :group_id, :integer, index: true
    add_column :home_pages, :subject_course_id, :integer, index: true
  end
end
