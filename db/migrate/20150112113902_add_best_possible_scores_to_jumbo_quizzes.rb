class AddBestPossibleScoresToJumboQuizzes < ActiveRecord::Migration
  def change
    add_column :course_module_jumbo_quizzes, :best_possible_score_first_attempt, :integer, default: 0
    add_column :course_module_jumbo_quizzes, :best_possible_score_retry, :integer, default: 0
  end
end
