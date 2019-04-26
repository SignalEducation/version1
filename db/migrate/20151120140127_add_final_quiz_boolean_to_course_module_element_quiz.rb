class AddFinalQuizBooleanToCourseModuleElementQuiz < ActiveRecord::Migration[4.2]
  def change
    add_column :course_module_element_quizzes, :is_final_quiz, :boolean, default: false, index: true
  end
end
