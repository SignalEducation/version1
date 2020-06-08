class OnboardingProcessCleanUp < ActiveRecord::Migration[5.2]
  def change
    rename_column :onboarding_processes, :subject_course_user_log_id, :course_log_id
  end
end
