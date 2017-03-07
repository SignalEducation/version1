class AddCompletedAtDatetimeToSubjectCourseUserLog < ActiveRecord::Migration
  def change
    add_column :subject_course_user_logs, :completed_at, :datetime
  end
end
