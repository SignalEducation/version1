class AddAttachmentsToExercises < ActiveRecord::Migration[5.2]
  def up
    add_attachment :exercises, :submission
    add_attachment :exercises, :correction
  end

  def down
    remove_attachment :exercises, :submission
    remove_attachment :exercises, :correction
  end
end
