class UpdatePreviousAttemptsWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'low'

  def perform(user_id, cme_id, cmeul_id)
    CourseStepLog.for_user(user_id).where(course_step_id: cme_id).where.not(id: cmeul_id).latest_only.update_all(latest_attempt: false)
  end

end
