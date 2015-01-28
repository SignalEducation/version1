class StudentExamTracksWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'medium'

  def perform(course_module_element_id)
    cme = CourseModuleElement.find(course_module_element_id)
    sets = StudentExamTrack.where(course_module_id: cme.course_module_id)
    sets.each do |set|
      set.recalculate_completeness
    end
  end

end
