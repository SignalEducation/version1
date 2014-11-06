class CreateCourseModules < ActiveRecord::Migration
  def change
    create_table :course_modules do |t|
      t.integer :institution_id, index: true
      t.integer :qualification_id, index: true
      t.integer :exam_level_id, index: true
      t.integer :exam_section_id, index: true
      t.string :name
      t.string :name_url, index: true
      t.text :description
      t.integer :tutor_id, index: true
      t.integer :sorting_order, index: true
      t.integer :estimated_time_in_seconds
      t.boolean :compulsory, default: false, null: false
      t.boolean :active, default: false, null: false

      t.timestamps
    end
  end
end
