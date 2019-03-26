class AddCourseSectionIdToCmAndCmeModels < ActiveRecord::Migration
  def change
    add_column :course_modules, :course_section_id, :integer
    add_column :course_module_elements, :course_section_id, :integer
  end
end
