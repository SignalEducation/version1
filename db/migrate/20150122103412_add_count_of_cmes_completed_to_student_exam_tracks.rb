class AddCountOfCmesCompletedToStudentExamTracks < ActiveRecord::Migration
  def change
    add_column :student_exam_tracks, :count_of_cmes_completed, :integer, default: 0
  end
end
