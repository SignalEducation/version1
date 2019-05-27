class AddSubmittedOnToExercises < ActiveRecord::Migration[5.2]
  def change
    add_column :exercises, :submitted_on, :datetime
  end
end
