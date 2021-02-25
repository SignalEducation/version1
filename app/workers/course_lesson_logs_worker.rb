class CourseLessonLogsWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'medium'

  def perform(set_id)
    set = CourseLessonLog.find(set_id)
    set.course_section_id = set.course_lesson.course_section_id
    set.recalculate_set_completeness
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error e.message
  end
end
