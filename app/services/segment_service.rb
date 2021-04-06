# frozen_string_literal: true

class SegmentService
  def identify_user(user)
    return unless user.email_verified && user.user_group == UserGroup.student_group

    Analytics.identify(
      user_id: user.id,
      traits: user_traits(user)
    )
  rescue StandardError => e
    Rails.logger.error "SegmentService#create_user - Error: #{e.inspect} - User Id #{user&.id}"
  end

  def track_verification_event(user)
    return unless user.email_verified && user.user_group == UserGroup.student_group

    Analytics.track(
      user_id: user.id,
      event: 'Email Verification',
      properties: verification_properties(user)
    )
  rescue StandardError => e
    Rails.logger.error "SegmentService#track_verification_event - #{e.inspect}"
  end

  def track_course_enrolment_event(enrolment, reset_progress)
    user = enrolment.user
    return unless user.email_verified && user.user_group == UserGroup.student_group

    Analytics.track(
      user_id: user.id,
      event: 'Course Enrolled',
      properties: enrolment_properties(enrolment, reset_progress)
    )
  rescue StandardError => e
    Rails.logger.error "SegmentService#track_verification_event - #{e.inspect}"
  end

  def track_correction_returned_event(exercise)
    user = exercise.user
    return unless user.email_verified && user.user_group == UserGroup.student_group

    Analytics.track(
      user_id: user.id,
      event: 'CBE Results Returned',
      properties: exercise_properties(exercise)
    )
  rescue StandardError => e
    Rails.logger.error "SegmentService#track_correction_returned_event - #{e.inspect}"
  end

  def track_enrolment_expiration_event(enrolment)
    user = enrolment.user
    return unless user.email_verified && user.user_group == UserGroup.student_group

    Analytics.track(
      user_id: user.id,
      event: 'Enrolment Expired',
      properties: enrolment_expiration_properties(enrolment, user)
    )
  rescue StandardError => e
    Rails.logger.error "SegmentService#track_enrolment_expiration_event - #{e.inspect}"
  end

  # PRIVATE ====================================================================

  private

  def user_traits(user)
    {
      name: user&.full_name,
      email: user&.email,
      firstName: user&.first_name,
      lastName: user&.last_name,
      createdAt: user&.created_at&.to_time&.iso8601,
      userGroup: user&.user_group&.name,
      stripeCustomerId: user&.stripe_customer_id,
      emailVerified: user&.email_verified,
      emailVerifiedAt: user&.email_verified_at&.to_time&.iso8601,
      preferredExamBody: user&.preferred_exam_body&.name,
      dateOfBirth: user&.date_of_birth,
      videoPlayerPreference: user&.video_player,
      currency: user&.currency&.name,
      onboardingStatus: user&.onboarding_state
    }
  end

  def verification_properties(user)
    {
      emailVerifiedAt: user&.email_verified_at&.to_time&.iso8601,
      examBodyId: user&.preferred_exam_body_id,
      examBodyName: user&.preferred_exam_body&.name
    }
  end

  def enrolment_properties(enrolment, reset_progress)
    {
      examBodyName: enrolment&.exam_body&.name,
      examBodyId: enrolment&.exam_body_id,
      courseName: enrolment&.course&.name,
      courseId: enrolment&.course_id,
      courseUserLogId: enrolment&.course_log_id,
      examSittingName: enrolment&.exam_sitting&.name,
      examSittingId: enrolment&.exam_sitting_id,
      resetProgress: reset_progress,
      previousEnrolmentCount: enrolment&.sibling_enrollments&.count
    }
  end

  def exercise_properties(exercise)
    {
      examBodyName: exercise&.product&.group&.exam_body&.name,
      examBodyId: exercise&.product&.group&.exam_body_id,
      courseName: exercise&.product&.course&.name,
      courseId: exercise&.product&.course_id,
      productName: exercise&.product&.name,
      productId: exercise&.product_id,
      cbeName: exercise&.product&.cbe&.name,
      cbeId: exercise&.product&.cbe_id
    }
  end

  def enrolment_expiration_properties(enrolment, user)
    {
      examBodyName: enrolment&.exam_body&.name,
      examBodyId: enrolment&.exam_body_id,
      courseName: enrolment&.course&.name,
      courseId: enrolment&.course_id,
      courseUserLogId: enrolment&.course_log_id,
      examSittingName: enrolment&.exam_sitting&.name,
      examSittingId: enrolment&.exam_sitting_id,
      previousEnrolmentCount: enrolment&.sibling_enrollments&.count,
      studentNumber: enrolment&.student_number,
      dateOfBirth: user&.date_of_birth,
      percentageComplete: enrolment&.course_log&.percentage_complete
    }
  end
end
