class RemoveCsIdFromCme < ActiveRecord::Migration[4.2]
  def change
    remove_column :course_module_elements, :course_section_id, :integer
  end
end
