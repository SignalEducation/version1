class AddCountOfQuestionsToStudentExamTracks < ActiveRecord::Migration[4.2]
  def change
    add_column :student_exam_tracks, :count_of_questions_taken, :integer
    add_column :student_exam_tracks, :count_of_questions_correct, :integer
  end
end
