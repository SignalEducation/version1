class EnrollmentExpirationWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'low'

  def perform(enrollment_id)
    enrollment = Enrollment.find(enrollment_id)
    if enrollment && !enrollment.expired
      if enrollment.computer_based_exam && enrollment.exam_date
        if Proc.new{Time.now.to_datetime}.call <= enrollment.exam_date.to_datetime
          # ComputerBased Enrollment triggered by after_create callback
          # Current datetime is less than the Enrollment exam_date
          # So should not be expired but trigger a new expiration worker
          EnrollmentExpirationWorker.perform_at(enrollment.exam_date.to_datetime + 23.hours, enrollment.id)
        else
          send_survey_message(enrollment_id)
        end
      else
        # Triggered by ExamSittingExpirationWorker
        send_survey_message(enrollment_id)
      end
      SegmentService.new.track_enrolment_expiration_event(enrollment)
    end
  end

  def send_survey_message(enrollment_id)
    enrollment = Enrollment.find(enrollment_id)
    enrollment.update(expired: true)

    return if enrollment.course&.survey_url.blank?

    Message.create(
      process_at: Time.zone.now,
      user_id: enrollment.user_id,
      kind: :account,
      template: 'send_survey_email',
      template_params: {
        url: enrollment&.course&.survey_url
      }
    )
  end

end
