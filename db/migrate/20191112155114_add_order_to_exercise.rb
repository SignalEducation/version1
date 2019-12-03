class AddOrderToExercise < ActiveRecord::Migration[5.2]
  def change
    add_reference :exercises, :order, index: true
  end
end
