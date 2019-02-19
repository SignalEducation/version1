class AddScoreToQuizAttempts < ActiveRecord::Migration[4.2]
  def change
    add_column :quiz_attempts, :score, :integer, default: 0
  end
end
