class CreateExamSections < ActiveRecord::Migration
  def change
    create_table :exam_sections do |t|
      t.string :name
      t.string :name_url, index: true
      t.integer :exam_level_id, index: true
      t.boolean :active, default: false, null: false
      t.integer :sorting_order, index: true
      t.float :best_possible_first_attempt_score

      t.timestamps
    end
  end
end
