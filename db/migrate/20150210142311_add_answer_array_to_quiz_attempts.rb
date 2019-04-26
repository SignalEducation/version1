class AddAnswerArrayToQuizAttempts < ActiveRecord::Migration[4.2]
  def change
    add_column :quiz_attempts, :answer_array, :string
  end
end
