class AddRelatedCourseModuleElementIdToCme < ActiveRecord::Migration[4.2]
  def change
    add_column :course_module_elements, :related_course_module_element_id, :integer, index: true
  end
end
