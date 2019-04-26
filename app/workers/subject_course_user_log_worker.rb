class SubjectCourseUserLogWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'medium'

  def perform(course_id)
    sculs = SubjectCourseUserLog.for_subject_course(course_id).all_incomplete

    sculs.each do |scul|
      scul.student_exam_tracks.each do |set|
        set.recalculate_set_completeness
      end
    end
  end

end
