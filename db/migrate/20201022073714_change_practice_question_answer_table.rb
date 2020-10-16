class ChangePracticeQuestionAnswerTable < ActiveRecord::Migration[5.2]
  def change
    remove_reference :course_step_logs, :current_practice_question_answer, index: true
    add_reference :practice_question_answers, :course_step_log, index: true
    remove_column :practice_question_answers, :solution
  end
end
