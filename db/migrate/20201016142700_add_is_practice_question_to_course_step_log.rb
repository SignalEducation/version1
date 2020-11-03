class AddIsPracticeQuestionToCourseStepLog < ActiveRecord::Migration[5.2]
  def change
    add_column :course_step_logs, :is_practice_question, :boolean, default: false
    add_reference :course_step_logs, :current_practice_question_answer, index: true
    add_foreign_key :course_step_logs, :practice_question_answers, column: :current_practice_question_answer_id
  end
end
