class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :name, index: true
      t.integer :subject_course_id, index: true
      t.integer :mock_exam_id, index: true
      t.string :stripe_guid, index: true
      t.boolean :live_mode, default: false

      t.timestamps null: false
    end
  end
end
