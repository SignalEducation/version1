class EnrollmentExpirationWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'low'

  def perform(enrollment_id)
    enrollment = Enrollment.find(enrollment_id)
    if enrollment && !enrollment.expired
      course = enrollment.course
      if enrollment.computer_based_exam && enrollment.exam_date
        if Proc.new{Time.now.to_datetime}.call <= enrollment.exam_date.to_datetime
          #ComputerBased Enrollment triggered by after_create callback
          #Current datetime is less than the Enrollment exam_date
          #So should not be expired but trigger a new expiration worker
          EnrollmentExpirationWorker.perform_at(enrollment.exam_date.to_datetime + 23.hours, enrollment.id)
        else
          enrollment.update_attributes(expired: true)
          MandrillWorker.perform_async(enrollment.user_id, 'send_survey_email', course.survey_url) if course.survey_url && !course.survey_url.empty?
        end
      else
        #Triggered by ExamSittingExpirationWorker
        enrollment.update_attributes(expired: true)
        MandrillWorker.perform_async(enrollment.user_id, 'send_survey_email', course.survey_url) if course.survey_url && !course.survey_url.empty?
      end
    end
  end

end
