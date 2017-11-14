class CronTasks

  def self.update_subject_course_user_logs
    courses = SubjectCourse.all_active
    courses.each do |course|
      time_now = Proc.new { Time.now }.call
      if course.updated_at > time_now - 7.days
        course.subject_course_user_logs.each do |set|
          SubjectCourseUserLogWorker.perform_at(5.minute.from_now, course.id)
        end
      end
    end
  end

  def self.process_free_trial_ended_users
    individual_user_group = UserGroup.default_student_user_group

    free_trial_users = User.where(free_trial: true).where(
        user_group_id: individual_user_group.id)

    free_trial_users.each do |user|
      if !user.subscriptions.any? &&
          !user.days_or_seconds_valid? &&
          user.free_trial_ended_at.nil? &&
          user.active?

        user.update_attribute(:free_trial_ended_at, Time.now)
      end
    end
  end

end
