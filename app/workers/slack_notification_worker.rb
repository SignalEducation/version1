class SlackNotificationWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'low'

  def perform(resource_type, resource_id, resource_action)
    klass = resource_type.to_s.camelize.constantize
    resource = klass.find(resource_id)
    resource.send(resource_action)
  end
end
