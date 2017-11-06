class ConditionalMandrillMailsProcessor
  class << self
    delegate :url_helpers, to: 'Rails.application.routes'
  end

  DAYS_WITHOUT_UPDATE = 3


  def self.process_we_havent_seen_you_in_a_while

    course_logs = SubjectCourseUserLog.where('updated_at > ? and updated_at < ?', DAYS_WITHOUT_UPDATE.days.ago.beginning_of_day, DAYS_WITHOUT_UPDATE.days.ago.end_of_day).where('percentage_complete < 100').order('updated_at desc')

    course_logs.each do |log|
      if log.enrollment
        course_name = log.subject_course.name
        days = DAYS_WITHOUT_UPDATE
        url = Rails.application.routes.url_helpers.library_course_url(group_name_url: log.subject_course.parent.name_url, subject_course_name_url: log.subject_course.name_url, host: ENV['LEARNSIGNAL_V3_SERVER_EMAIL_DOMAIN'])
        MandrillWorker.perform_async(log.user.id, 'send_we_havent_seen_you_in_a_while_email', url, course_name, days) if log
      end
    end
  end

end
