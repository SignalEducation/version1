class AddExerciseIdToCbeUserLog < ActiveRecord::Migration[5.2]
  def change
    add_reference :cbe_user_logs, :exercise, index: true
  end
end
