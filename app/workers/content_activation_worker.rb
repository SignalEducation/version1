class ContentActivationWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'medium'

  # type could be any of this classes
  # CourseStep
  # CourseResource
  # ContentPage
  # HomePage
  def perform(type, id)
    record = type.constantize.find(id)
    record.update!(active: true)
  end
end
