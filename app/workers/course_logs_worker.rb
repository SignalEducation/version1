# frozen_string_literal: true

class CourseLogsWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'medium'

  def perform(name, email, group_id)
    Accredible::Credentials.new.create(name, email, group_id)
  end
end
