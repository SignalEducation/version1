class AddActiveBooleanToCourseModuleJumboQuiz < ActiveRecord::Migration[4.2]
  def change
    add_column :course_module_jumbo_quizzes, :active, :boolean, index: true, default: false, null: false
  end
end
