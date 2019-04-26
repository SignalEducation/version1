class AddActiveToCourseModuleElements < ActiveRecord::Migration[4.2]
  def change
    add_column :course_module_elements, :active, :boolean, index: true, default: true, null: false
  end
end
