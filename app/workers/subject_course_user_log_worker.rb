class SubjectCourseUserLogWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'medium'

  def perform(subject_course_id)
    SubjectCourseUserLog.where(subject_course_id: subject_course_id).find_each do |log|
      log.recalculate_completeness
    end
  end

end
