class EnrollmentExpirationWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'low'

  def perform(enrollment_id)
    enrollment = Enrollment.find(enrollment_id)
    if enrollment && !enrollment.expired
      if enrollment.computer_based_exam && enrollment.exam_date
        if enrollment.exam_date.to_datetime <= Proc.new{Time.now.to_datetime}.call
          #ComputerBased Enrollment triggered by after_create callback
          #Enrollment exam_date is not greater than the current datetime
          #So should not be expired
          EnrollmentExpirationWorker.perform_at(enrollment.exam_date.to_datetime + 23.hours, enrollment.id)
        else
          enrollment.update_attributes(expired: true, notifications: false)
        end
      else
        #Triggered by ExamSittingExpirationWorker
        enrollment.update_attributes(expired: true, notifications: false)
      end
    end
  end

end
