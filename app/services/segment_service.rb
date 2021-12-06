# frozen_string_literal: true

class SegmentService
  def identify_user(user)
    return unless user.email_verified

    segment = Analytics.identify(
      user_id: user.id,
      traits: user_traits(user).reverse_merge!(subscriptions_statuses(user))
    )
  rescue StandardError => e
    Rails.logger.error "SegmentService#create_user - Error: #{e.inspect} - User Id #{user&.id} Segment Object - #{segment}"
  end

  def track_verification_event(user)
    return unless user.email_verified

    segment = Analytics.track(
      user_id: user.id,
      event: 'Email Verification',
      properties: verification_properties(user)
    )
  rescue StandardError => e
    Rails.logger.error "SegmentService#track_verification_event - #{e.inspect} Segment Object - #{segment}"
  end

  def track_course_enrolment_event(enrolment, reset_progress, banner)
    user = enrolment.user
    return unless user.email_verified

    segment = Analytics.track(
      user_id: user.id,
      event: 'Course Enrolled',
      properties: enrolment_properties(enrolment, reset_progress, banner)
    )
  rescue StandardError => e
    Rails.logger.error "SegmentService#track_verification_event - #{e.inspect} Segment Object - #{segment}"
  end

  def track_enrolment_expiration_event(enrolment)
    user = enrolment.user
    return unless user.email_verified

    segment = Analytics.track(
      user_id: user.id,
      event: 'Enrolment Expired',
      properties: enrolment_expiration_properties(enrolment, user)
    )
  rescue StandardError => e
    Rails.logger.error "SegmentService#track_enrolment_expiration_event - #{e.inspect} Segment Object - #{segment}"
  end

  def track_correction_returned_event(exercise)
    user = exercise.user
    return unless user.email_verified

    segment = Analytics.track(
      user_id: user.id,
      event: 'CBE Results Returned',
      properties: exercise_properties(exercise)
    )
  rescue StandardError => e
    Rails.logger.error "SegmentService#track_correction_returned_event - #{e.inspect} Segment Object - #{segment}"
  end

  def track_payment_complete_event(user, subscription)
    segment = Analytics.track(
      user_id: user.id,
      event: 'successful_payment',
      properties: payment_properties(subscription.subscription_plan, subscription.coupon_data, subscription.kind, user&.email)
    )
  rescue StandardError => e
    Rails.logger.error "SegmentService#create_user - Error: #{e.inspect} - User Id #{user&.id} Segment Object - #{segment}"
  end

  def track_payment_failed_event(user, subscription, error_msg, error_code)
    segment = Analytics.track(
      user_id: user&.id,
      event: 'payment_failed',
      properties: payment_properties(subscription.subscription_plan, subscription.coupon_data, subscription.kind, user&.email).merge!(payment_error_properties(error_msg, error_code))
    )
  rescue StandardError => e
    Rails.logger.error "SegmentService#create_& - Error: #{e.inspect} - User Id #{user&.id} Segment Object - #{segment}"
  end

  def track_user_account_created_event(user, analytics_attributes)
    attributes = analytics_attributes_properties(analytics_attributes.with_indifferent_access)
    return if attributes.nil?

    segment = Analytics.track(
      user_id: user.id,
      event: 'user_account_created',
      properties: attributes
    )
  rescue StandardError => e
    Rails.logger.error "SegmentService#user_account_created - Error: #{e.inspect} - User Id #{user&.id} Segment Object - #{segment}"
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
      onboardingEmailStatus: user&.onboarding_state,
      onboardingStatus: user&.analytics_onboarding_state
    }
  end

  def verification_properties(user)
    {
      emailVerifiedAt: user&.email_verified_at&.to_time&.iso8601,
      preferredExamBodyId: user&.preferred_exam_body_id,
      preferredExamBody: user&.preferred_exam_body&.name,
      examBodyId: user&.preferred_exam_body_id,
      examBodyName: user&.preferred_exam_body&.name,
      onboarding: 'false',
      banner: 'false'
    }
  end

  def enrolment_properties(enrolment, reset_progress, banner)
    {
      preferredExamBodyId: enrolment&.user&.preferred_exam_body_id,
      preferredExamBody: enrolment&.user&.preferred_exam_body&.name,
      examBodyName: enrolment&.exam_body&.name,
      examBodyId: enrolment&.exam_body_id,
      courseName: enrolment&.course&.name,
      courseId: enrolment&.course_id,
      courseUserLogId: enrolment&.course_log_id,
      examSittingName: enrolment&.exam_sitting&.name,
      examSittingId: enrolment&.exam_sitting_id,
      enrolmentId: enrolment&.id,
      resetProgress: reset_progress,
      previousEnrolmentCount: enrolment&.sibling_enrollments&.count,
      onboarding: enrolment.user&.analytics_onboarding_valid?.to_s,
      banner: banner
    }
  end

  def exercise_properties(exercise)
    {
      preferredExamBodyId: exercise&.user&.preferred_exam_body_id,
      preferredExamBody: exercise&.user&.preferred_exam_body&.name,
      onboarding: exercise&.user&.analytics_onboarding_valid?.to_s,
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
      preferredExamBodyId: user&.preferred_exam_body_id,
      preferredExamBody: user&.preferred_exam_body&.name,
      examBodyName: enrolment&.exam_body&.name,
      examBodyId: enrolment&.exam_body_id,
      courseName: enrolment&.course&.name,
      courseId: enrolment&.course_id,
      courseUserLogId: enrolment&.course_log_id,
      examSittingName: enrolment&.exam_sitting&.name,
      examSittingId: enrolment&.exam_sitting_id,
      enrolmentId: enrolment&.id,
      previousEnrolmentCount: enrolment&.sibling_enrollments&.count,
      studentNumber: enrolment&.student_number,
      dateOfBirth: user&.date_of_birth,
      percentageComplete: enrolment&.course_log&.percentage_complete,
      onboarding: user&.analytics_onboarding_valid?.to_s
    }
  end

  def payment_properties(plan, coupon_data, payment_type, email)
    {
      email: email,
      programName: plan.exam_body&.name,
      planName: "#{plan.name} - #{plan.interval_name}",
      discountedPrice: coupon_data.present? ? coupon_data[:price_discounted]&.round(2) : '',
      discountCode: coupon_data.present? ? coupon_data[:code] : '',
      planPrice: plan&.amount,
      currency: plan&.currency&.name,
      paymentType: payment_type&.camelize(:lower),
      subscriptionType: 'Subscription',
      planType: plan&.interval_name&.downcase
    }
  end

  def payment_error_properties(error_msg, error_code)
    {
      error_code: error_code,
      error_reason: error_msg
    }
  end

  def analytics_attributes_properties(analytics_attributes)
    valid_keys = %i[category clientOs deviceType email eventSentAt isLoggedIn pageUrl platform
                    programName sessionId sourceofRegistration]

    return nil unless valid_keys.all? { |s| analytics_attributes.key? s }

    {
      category: analytics_attributes[:category],
      deviceType: analytics_attributes[:deviceType],
      email: analytics_attributes[:email],
      eventSentAt: analytics_attributes[:eventSentAt],
      isLoggedIn: analytics_attributes[:isLoggedIn],
      pageUrl: analytics_attributes[:pageUrl],
      platform: analytics_attributes[:platform],
      programName: analytics_attributes[:programName],
      sessionId: analytics_attributes[:sessionId],
      sourceofRegistration: analytics_attributes[:sourceofRegistration]
    }
  end

  def subscriptions_statuses(user, statuses = {})
    ExamBody.where(active: true).each do |body|
      group = Group.find_by(exam_body_id: body.id)
      subscriptions_for_body = user.subscriptions.for_exam_body(body.id).where.not(state: :pending).order(created_at: :desc)
      lifetime_access_for_body = user.orders.for_group(group.id).for_lifetime_access.where(state: :completed).order(created_at: :desc) if group

      account_status =
        if lifetime_access_for_body&.any?
          'Lifetime Membership'
        elsif subscriptions_for_body.any?
          subscriptions_for_body.first.user_readable_status
        else
          'Basic'
        end

      statuses[body&.hubspot_property&.parameterize(separator: '_')&.to_sym] = account_status
    end

    statuses
  end
end
