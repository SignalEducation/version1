class CreateCourseTutorDetails < ActiveRecord::Migration[4.2]
  def change
    create_table :course_tutor_details do |t|
      t.integer :subject_course_id, index: true
      t.integer :user_id, index: true
      t.integer :sorting_order
      t.string :title

      t.timestamps null: false
    end
  end
end
