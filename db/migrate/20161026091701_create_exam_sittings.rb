class CreateExamSittings < ActiveRecord::Migration[4.2]
  def change
    create_table :exam_sittings do |t|
      t.string :name, index: true
      t.integer :subject_course_id, index: true
      t.date :date, index: true

      t.timestamps null: false
    end
  end
end
