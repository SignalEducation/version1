class EnrollmentExpirationEventWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'low'

  def perform(enrollment_id)
    enrollment = Enrollment.find(enrollment_id)
    if !enrollment.expired && enrollment.exam_date.to_datetime <= Proc.new{Time.now.to_datetime}.call
      enrollment.update_attribute(:expired, true)
    end
  end

end
