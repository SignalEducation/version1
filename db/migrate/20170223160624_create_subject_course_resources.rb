class CreateSubjectCourseResources < ActiveRecord::Migration
  def change
    create_table :subject_course_resources do |t|
      t.string :name, index: true
      t.integer :subject_course_id, index: true
      t.text :description

      t.timestamps null: false
    end
  end
end
