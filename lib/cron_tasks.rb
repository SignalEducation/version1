# frozen_string_literal: true

class CronTasks
  def self.update_course_logs
    courses = Course.all_active
    courses.each do |course|
      time_now = Proc.new { Time.now }.call
      if course.updated_at > time_now - 7.days
        course.course_logs.each do |scul|
          CourseLogWorker.perform_at(5.minute.from_now, scul.course_id)
        end
      end
    end
  end
end
