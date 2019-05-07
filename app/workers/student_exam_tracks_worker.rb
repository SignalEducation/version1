class StudentExamTracksWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'medium'

  def perform(set_id)
    set = StudentExamTrack.find(set_id)
    set.course_section_id = set.course_module.course_section_id
    set.recalculate_set_completeness
  end

end
