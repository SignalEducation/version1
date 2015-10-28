class StudentExamTracksWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'low'

  def perform(course_module_id)
    StudentExamTrack.where(course_module_id: course_module_id).find_each do |set|
      set.recalculate_completeness
    end
  end

end
