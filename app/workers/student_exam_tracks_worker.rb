class StudentExamTracksWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'medium'

  def perform(course_module_id)
    StudentExamTrack.where(course_module_id: course_module_id).find_each do |set|
      set.worker_update_completeness
    end
  end

end
