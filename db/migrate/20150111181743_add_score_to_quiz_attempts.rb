class AddScoreToQuizAttempts < ActiveRecord::Migration
  def change
    add_column :quiz_attempts, :score, :integer, default: 0
  end
end
