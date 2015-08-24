class AddNumberOfQuestionsToCourseModuleAndCourseModuleElement < ActiveRecord::Migration
  def change
    add_column :course_modules, :number_of_questions, :integer, index: true, default: 0
    add_column :course_module_elements, :number_of_questions, :integer, index: true, default: 0
  end
end
