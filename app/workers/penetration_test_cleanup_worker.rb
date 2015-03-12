class PenetrationTestCleanupWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'medium'

  def perform(user_id, session_guid)

    UserActivityLog.where(user_id: user_id, session_guid: session_guid).destroy_all
    UserActivityLog.where(session_guid: session_guid).destroy_all
  end

end
