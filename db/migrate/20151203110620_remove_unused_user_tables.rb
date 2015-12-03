class RemoveUnusedUserTables < ActiveRecord::Migration
  def change
    drop_table :user_likes
    drop_table :user_exam_levels
  end
end
