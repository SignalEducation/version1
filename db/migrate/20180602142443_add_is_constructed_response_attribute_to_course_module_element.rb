class AddIsConstructedResponseAttributeToCourseModuleElement < ActiveRecord::Migration
  def change
    add_column :course_module_elements, :is_constructed_response, :boolean, default: false, null: false, index: true
  end
end
