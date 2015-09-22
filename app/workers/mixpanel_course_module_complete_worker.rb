class MixpanelCourseModuleCompleteWorker
  include Sidekiq::Worker
  require 'mixpanel-ruby'

  sidekiq_options queue: 'high'

  def perform(user_id, cm_name, subject_course, video_count, quiz_count)
    tracker1 = Mixpanel::Tracker.new(ENV['mixpanel_key'])
    tracker1.track(user_id, 'CM completed', {
              'CM' => cm_name,
              'course' => subject_course,
              'videos_count' => video_count,
              'quizzes_count'=> quiz_count
    })
    Rails.logger.debug "DEBUG: StudentExamTrack#send_cm_complete_to_mixpanel for user #{user_id}. Tracker:#{tracker1.inspect}."
  end

end
