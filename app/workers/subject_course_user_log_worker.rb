class SubjectCourseUserLogWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'medium'

  def perform(course_id)
    sculs = SubjectCourseUserLog.for_subject_course(course_id)

    sculs.each do |scul|
      if scul.active_enrollment
        scul.student_exam_tracks.each do |set|
          set.worker_update_completeness
        end
        scul.recalculate_completeness
      end
    end
  end

end
