class IntercomCourseEnrolledEventWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'low'

  def perform(user_id, course_name, exam_date)
    IntercomNewEnrollmentService.new({user_id: user_id, course_name: course_name, exam_date: exam_date}).perform
  end

end
