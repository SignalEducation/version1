class CreateUserExamLevels < ActiveRecord::Migration
  def change
    create_table :user_exam_levels do |t|
      t.integer :user_id, index: true
      t.integer :exam_level_id, index: true
      t.integer :exam_schedule_id, index: true

      t.timestamps
    end
  end
end
