class AddBestScoreAndNumberOfAnswersToSubjectCourse < ActiveRecord::Migration[4.2]
  def change
    add_column :subject_courses, :best_possible_first_attempt_score, :float
    add_column :subject_courses, :default_number_of_possible_exam_answers, :integer
  end
end
