class AddCompletedAtDatetimeToSubjectCourseUserLog < ActiveRecord::Migration[4.2]
  def change
    add_column :subject_course_user_logs, :completed_at, :datetime
  end
end
