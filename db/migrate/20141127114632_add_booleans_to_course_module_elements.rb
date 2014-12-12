class AddBooleansToCourseModuleElements < ActiveRecord::Migration
  def change
    add_column :course_module_elements, :is_video, :boolean, index: true, default: false, null: false
    add_column :course_module_elements, :is_quiz, :boolean, index: true, default: false, null: false
  end
end
