class SubjectCourseUserLogWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'medium'

  def perform(course_id)
    sculs = SubjectCourseUserLog.for_subject_course(course_id).all_incomplete

    sculs.each do |scul|
      scul.create_missing_sets_and_csuls

      scul.student_exam_tracks.each do |set|
        StudentExamTracksWorker.perform_async(set.id)
      end

    end
  end

end
