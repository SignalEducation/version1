class ChangePercentageCompleteToFloatInStudentExamTracks < ActiveRecord::Migration
  def up
    change_column :student_exam_tracks, :percentage_complete, :float
  end

  def down
    change_column :student_exam_tracks, :percentage_complete, :integer
  end
end
