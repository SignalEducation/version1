class AddQuestionNameToPracticeQuestionQuestion < ActiveRecord::Migration[5.2]
  def change
    add_column :practice_question_questions, :name, :string
  end
end
