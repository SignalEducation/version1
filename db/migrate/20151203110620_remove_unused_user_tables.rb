class RemoveUnusedUserTables < ActiveRecord::Migration[4.2]
  def change
    drop_table :user_likes
    drop_table :user_exam_levels
  end
end
