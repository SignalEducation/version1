class ExamSittingExpirationWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'low'

  def perform(exam_sitting_id)
    sitting = ExamSitting.find(exam_sitting_id)

    return unless sitting

    if Time.now.in_time_zone.to_date >= sitting.date
      sitting.update_attribute(:active, false)
      sitting.enrollments.each do |enrollment|
        EnrollmentExpirationWorker.perform_async(enrollment.id)
      end
    else
      ExamSittingExpirationWorker.perform_at(sitting.date.to_datetime + 23.hours, sitting.id)
    end
  end

end
