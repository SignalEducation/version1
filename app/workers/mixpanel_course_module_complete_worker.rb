class MixpanelCourseModuleCompleteWorker
  include Sidekiq::Worker
  require 'mixpanel-ruby'

  sidekiq_options queue: 'high'

  def perform(user_id, cm_name, es_name, el_name, qual_name, inst_name, subject_area, video_count, quiz_count)
    tracker1 = Mixpanel::Tracker.new(ENV['mixpanel_key'])
    tracker1.track(user_id, 'CM completed', {
              'CM' => cm_name,
              'exam_section' => es_name,
              'exam_level' => el_name,
              'qualification'  => qual_name,
              'institution' => inst_name,
              'subject_area' => subject_area,
              'videos_count' => video_count,
              'quizzes_count'=> quiz_count
    })
    Rails.logger.debug "DEBUG: StudentExamTrack#send_cm_complete_to_mixpanel for user #{user_id}. Tracker:#{tracker1.inspect}."
  end

end
