class CreateStudentExamTracks < ActiveRecord::Migration
  def change
    create_table :student_exam_tracks do |t|
      t.integer :user_id, index: true
      t.integer :exam_level_id, index: true
      t.integer :exam_section_id, index: true
      t.integer :latest_course_module_element_id, index: true
      t.integer :exam_schedule_id, index: true

      t.timestamps
    end
  end
end
