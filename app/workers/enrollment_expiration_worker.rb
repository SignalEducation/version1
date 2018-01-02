class EnrollmentExpirationWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'low'

  def perform(enrollment_id)
    enrollment = Enrollment.find(enrollment_id)
    if enrollment && !enrollment.expired && enrollment.exam_date && enrollment.exam_date.to_datetime <= Proc.new{Time.now.to_datetime}.call
      enrollment.update_attributes(expired: true, notifications: false)
    end
  end

end
