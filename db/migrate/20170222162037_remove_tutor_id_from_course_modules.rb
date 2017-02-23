class RemoveTutorIdFromCourseModules < ActiveRecord::Migration
  def change
    remove_column :course_modules, :tutor_id, :integer
    remove_column :course_module_elements, :tutor_id, :integer
  end
end
