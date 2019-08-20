class AddQuestionFieldsToCbeMultipleChoiceQuestion < ActiveRecord::Migration[5.2]
  def change
    add_column :cbe_multiple_choice_questions, :question_1, :string
    add_column :cbe_multiple_choice_questions, :question_2, :string
    add_column :cbe_multiple_choice_questions, :question_3, :string
    add_column :cbe_multiple_choice_questions, :question_4, :string
    add_column :cbe_multiple_choice_questions, :correct_answer, :integer
  end
end
