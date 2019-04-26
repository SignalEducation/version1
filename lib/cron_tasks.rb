class CronTasks

  def self.update_subject_course_user_logs
    courses = SubjectCourse.all_active
    courses.each do |course|
      time_now = Proc.new { Time.now }.call
      if course.updated_at > time_now - 7.days
        course.subject_course_user_logs.each do |scul|
          SubjectCourseUserLogWorker.perform_at(5.minute.from_now, scul.subject_course_id)
        end
      end
    end
  end


end
