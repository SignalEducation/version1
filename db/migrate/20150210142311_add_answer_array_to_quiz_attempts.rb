class AddAnswerArrayToQuizAttempts < ActiveRecord::Migration
  def change
    add_column :quiz_attempts, :answer_array, :string
  end
end
