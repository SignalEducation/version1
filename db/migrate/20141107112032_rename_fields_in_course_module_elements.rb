class RenameFieldsInCourseModuleElements < ActiveRecord::Migration
  def up
    rename_column :course_module_elements, :course_video_id, :course_module_element_video_id
    rename_column :course_module_elements, :course_quiz_id, :course_module_element_quiz_id
  end

  def down
    rename_column :course_module_elements, :course_module_element_video_id, :course_video_id
    rename_column :course_module_elements, :course_module_element_quiz_id, :course_quiz_id
  end
end
