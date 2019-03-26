class AddRelatedCourseModuleElementIdToCme < ActiveRecord::Migration
  def change
    add_column :course_module_elements, :related_course_module_element_id, :integer, index: true
  end
end
