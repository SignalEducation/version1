class SegmentService
  require 'segment/analytics'

  def initialize
    @segment_analytics = Segment::Analytics.new({
                                                  write_key: ENV['LEARNSIGNAL_SEGMENT_KEY'],
                                                  on_error: Proc.new { |status, msg| Rails.logger.error "DEBUG: Segment error - #{msg}" }
                                                })

  end

  def analytics_identify_user(list_id, user_id, exam_body_id)
    user = User.find(user_id)
    exam_body = ExamBody.find(exam_body_id)
    #student_number = user.exam_body_user_details
    @segment_analytics.identify(user_id: user_id,
                       traits: {
                           email: user.email,
                           first_name: user.first_name,
                           last_name: user.last_name,
                           dob: user.date_of_birth,
                           pref_body: exam_body.name,
                           f5_december_2018: true
                       }
    )
  end

  def analytics_identify_enrollment(list_id, user_id, enrollment_id)
    user = User.find(user_id)
    enrollment = Enrollment.find(enrollment_id)
    @segment_analytics.track(
        user_id: user_id,
        event: 'Course Enrolment',
        properties: {
            sitting: enrollment.exam_sitting.name,
            messaging: enrollment.notifications
        }
    )
  end

end
