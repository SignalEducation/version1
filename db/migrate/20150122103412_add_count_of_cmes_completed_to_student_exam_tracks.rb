class AddCountOfCmesCompletedToStudentExamTracks < ActiveRecord::Migration[4.2]
  def change
    add_column :student_exam_tracks, :count_of_cmes_completed, :integer, default: 0
  end
end
