class AddIsConstructedResponseAttributeToCourseModuleElement < ActiveRecord::Migration[4.2]
  def change
    add_column :course_module_elements, :is_constructed_response, :boolean, default: false, null: false, index: true
  end
end
