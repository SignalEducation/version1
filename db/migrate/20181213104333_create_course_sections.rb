class CreateCourseSections < ActiveRecord::Migration
  def change
    create_table :course_sections do |t|
      t.integer :subject_course_id, index: true
      t.string :name, index: true
      t.string :name_url
      t.integer :sorting_order
      t.boolean :active, default: false
      t.boolean :counts_towards_completion, default: false
      t.boolean :assumed_knowledge, default: false

      t.timestamps null: false
    end
  end


end
