class RemoveFieldsFromCourseModuleElementVideoModel < ActiveRecord::Migration
  def change
    remove_column :course_module_element_videos, :tags, :string
    remove_column :course_module_element_videos, :difficulty_level, :string
    remove_column :course_module_element_videos, :transcript, :text
    remove_column :course_module_element_videos, :thumbnail, :text
  end
end
