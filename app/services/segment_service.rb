# frozen_string_literal: true

class SegmentService
  def identify_user(user)
    return unless user.email_verified && user.user_group == UserGroup.student_group

    Analytics.identify(
      user_id: user.id,
      traits: user_traits(user)
    )
  rescue StandardError => e
    Rails.logger.error "SegmentService#create_user - #{e.inspect}"
    # ApplicationController.log_in_airbrake("Segment: Create User #{user.id}: #{e.message}")
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

  # PRIVATE ====================================================================

  private

  def user_traits(user)
    {
      name: user.full_name,
      email: user.email,
      first_name: user.first_name,
      last_name: user.last_name,
      created_at: user.created_at.to_time.iso8601,
      user_group: user.user_group.name,
      stripe_customer_id: user.stripe_customer_id,
      email_verified: user.email_verified,
      email_verified_at: user.email_verified_at.to_time.iso8601,
      preferred_exam_body: user.preferred_exam_body.name,
      date_of_birth: user.date_of_birth,
      video_player_preference: user.video_player,
      currency: user.currency.name,
      onboarding_status: user.onboarding_state
    }
  end

  def verification_properties(user)
    {
      email_verified_at: user.email_verified_at.to_time.iso8601,
      exam_body_id: user.preferred_exam_body_id,
      exam_body_name: user.preferred_exam_body.name
    }
  end
end
