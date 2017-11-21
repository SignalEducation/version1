class TrialExpirationWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'medium'

  def perform(user_id)
    user = User.find(user_id)
    time_now =Proc.new{Time.now.to_datetime}.call

    if user && user.student_user? && user.student_access
      student_access = user.student_access

      if student_access.trial_ended_date == nil && ((time_now >= student_access.trial_ending_at_date) || student_access.content_seconds_consumed >= student_access.trial_seconds_limit)
        user.student_access.update_attributes(trial_end_date: time_now, content_access: false)
      else
        trial_ending_at_date = student_access.trial_ending_at_date + 23.hours
        TrialExpirationWorker.perform_at(trial_ending_at_date, user.id)
      end
    end
  end

end
