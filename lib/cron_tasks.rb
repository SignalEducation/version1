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
end
