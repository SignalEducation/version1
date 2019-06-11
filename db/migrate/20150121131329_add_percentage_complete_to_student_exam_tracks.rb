class AddPercentageCompleteToStudentExamTracks < ActiveRecord::Migration[4.2]
  def change
    add_column :student_exam_tracks, :percentage_complete, :integer, default: 0
  end
end
