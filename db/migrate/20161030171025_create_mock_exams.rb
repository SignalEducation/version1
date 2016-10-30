class CreateMockExams < ActiveRecord::Migration
  def change
    create_table :mock_exams do |t|
      t.integer :subject_course_id, index: true
      t.integer :product_id, index: true
      t.string :name, index: true
      t.integer :sorting_order

      t.timestamps null: false
    end
  end
end
