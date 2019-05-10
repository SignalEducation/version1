class AddCorrectedOnToExercises < ActiveRecord::Migration[5.2]
  def change
    add_column :exercises, :corrected_on, :datetime
    add_column :exercises, :returned_on, :datetime
  end
end
