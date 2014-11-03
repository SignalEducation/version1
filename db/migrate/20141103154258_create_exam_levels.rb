class CreateExamLevels < ActiveRecord::Migration
  def change
    create_table :exam_levels do |t|
      t.integer :qualification_id, index: true
      t.string :name
      t.string :name_url
      t.boolean :is_cpd, default: false, null: false
      t.integer :sorting_order
      t.boolean :active, default: false, null: false
      t.float :best_possible_first_attempt_score

      t.timestamps
    end
  end
end
