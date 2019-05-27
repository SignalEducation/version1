class AddUserAndCorrectorToExercises < ActiveRecord::Migration[5.2]
  def change
    add_reference :exercises, :user, foreign_key: true
    add_reference :exercises, :corrector, foreign_key: { to_table: :users }
  end
end
