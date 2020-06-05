class ChangeOnboardingProcessRelationshipToCourse < ActiveRecord::Migration[5.2]
  def change
    rename_column :onboarding_processes, :student_exam_track_id, :subject_course_user_log_id
  end
end
