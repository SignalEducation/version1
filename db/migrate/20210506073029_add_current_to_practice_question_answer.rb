class AddCurrentToPracticeQuestionAnswer < ActiveRecord::Migration[5.2]
  def change
    add_column :practice_question_answers, :current, :boolean, default: false
  end
end
