class CreateUserExamLevels < ActiveRecord::Migration
  def change
    create_table :user_exam_levels do |t|
      t.integer :user_id
      t.integer :exam_level_id
      t.integer :exam_schedule_id

      t.timestamps
    end
  end
end
