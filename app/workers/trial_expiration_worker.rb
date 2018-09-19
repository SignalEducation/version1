class TrialExpirationWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'medium'

  def perform(user_id)
    user = User.find(user_id)
    if user && user.student_user? && user.student_access
      user.student_access.check_trial_access_is_valid
    end
  end

end
