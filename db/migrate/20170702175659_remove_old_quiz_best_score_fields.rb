class RemoveOldQuizBestScoreFields < ActiveRecord::Migration
  def change
    remove_column :course_module_element_quizzes, :best_possible_score_first_attempt, :integer
    remove_column :course_module_element_quizzes, :best_possible_score_retry, :integer
    remove_column :quiz_questions, :hints, :integer
  end
end
