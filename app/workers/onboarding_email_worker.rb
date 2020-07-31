# frozen_string_literal: true

class OnboardingEmailWorker
  include Sidekiq::Worker

  sidekiq_options queue: 'medium'

  def perform(onboarding_process_id, day)
    onboarding_process = OnboardingProcess.find(onboarding_process_id)
    user               = onboarding_process.user
    exam_body_id       = onboarding_process.exam_body.id

    return unless onboarding_process.active

    if user&.active_subscriptions_for_exam_body(exam_body_id).any?
      onboarding_process.update(active: false)
    else
      onboarding_process.send_email(day)
    end
  end
end
