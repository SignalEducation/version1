class AddStuffToStudentExamTracks < ActiveRecord::Migration[4.2]
  def change
    add_column :student_exam_tracks, :session_guid, :string, index: true
    add_column :student_exam_tracks, :course_module_id, :integer, index: true
    add_column :student_exam_tracks, :jumbo_quiz_taken, :boolean, default: false
  end
end
