class AddCountAttributesForConstructedResponsesTosculAndSetModels < ActiveRecord::Migration[4.2]
  def change
    add_column :student_exam_tracks, :count_of_constructed_responses_taken, :integer
    add_column :subject_course_user_logs, :count_of_constructed_responses_taken, :integer
  end
end
