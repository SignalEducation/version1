class CreateExercises < ActiveRecord::Migration[5.2]
  def change
    create_table :exercises do |t|
      t.references :product, foreign_key: true
      t.string :state

      t.timestamps
    end
  end
end
