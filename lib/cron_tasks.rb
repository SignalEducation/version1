class CronTasks

  def self.process_student_exam_tracks

    all_course_modules = CourseModule.all_active

    all_course_modules.each do |cm|
      time_now = Proc.new { Time.now }.call
      if cm.updated_at > time_now - 7.days
        cm.student_exam_tracks.each do |set|
          StudentExamTracksWorker.perform_async(set.id)
        end
        SubjectCourseUserLogWorker.perform_at(5.minute.from_now, cm.subject_course_id)
      end
    end
  end

  def self.pause_inactive_enrollments

    all_enrollments = Enrollment.all_active

    all_enrollments.each do |enrollment|
      time_now = Proc.new { Time.now }.call
      if enrollment.updated_at < time_now - 6.months
        enrollment.update_attribute(:active, false)
      end
    end
  end

  def self.create_course_progress_intercom_worker

    all_enrollments = Enrollment.where('updated_at >= ?', 1.week.ago).all_active

    all_enrollments.each do |enrollment|
      IntercomCourseProgressEventWorker.perform_async(enrollment.user_id, self.subject_course.name, self.rounded_percentage_complete)
    end
  end

end
