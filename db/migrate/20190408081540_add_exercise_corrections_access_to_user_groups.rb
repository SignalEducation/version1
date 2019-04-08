class AddExerciseCorrectionsAccessToUserGroups < ActiveRecord::Migration[5.2]
  def change
    add_column :user_groups, :exercise_corrections_access, :boolean, default: false
  end
end
