# frozen_string_literal: true

# == Schema Information
#
# Table name: onboarding_processes
#
#  id            :bigint           not null, primary key
#  user_id       :integer
#  course_log_id :integer
#  active        :boolean          default("true"), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
class OnboardingProcess < ApplicationRecord
  belongs_to :user
  belongs_to :course_log

  validates :user_id, presence: true
  validates :course_log_id, presence: true

  after_create :create_workers

  def content_remaining?
    free_step_ids           = course_log.course.free_course_steps.map(&:id).sort
    completed_log_step_ids  = course_log.course_step_logs.all_completed.map(&:course_step_id).sort

    free_step_ids != completed_log_step_ids
  end

  def next_step
    course_log&.latest_course_step&.next_free_step
  end

  def send_email(day)
    if day == 6
      Message.create(process_at: Time.zone.now, user_id: user&.id, kind: :onboarding, template: 'send_onboarding_expired_email', template_params: { course: course_log.course.group.name,
                                                                                                                                                  url: UrlHelper.instance.new_subscription_url(exam_body_id: course_log.course.exam_body_id, host: LEARNSIGNAL_HOST, utm_campaign: 'OnboardingEmails', utm_content: 'send_onboarding_expired_email') })
      update(active: false)
      # TODO -Trigger HubSpot
    elsif !content_remaining?
      Message.create(process_at: Time.zone.now, user_id: user&.id, kind: :onboarding, template: 'send_onboarding_complete_email', template_params: { course: course_log.course.group.name,
                                                                                                                                           url: UrlHelper.instance.new_subscription_url(exam_body_id: course_log.course.exam_body_id, host: LEARNSIGNAL_HOST, utm_campaign: 'OnboardingEmails', utm_content: 'send_onboarding_complete_email') })
      update(active: false)
      # TODO -Trigger HubSpot
    elsif next_step
      Message.create(process_at: Time.zone.now, user_id: user&.id, kind: :onboarding, template: 'send_onboarding_content_email', template_params: { day: day, subject: "#{course_log.course&.group&.name} Exams: Welcome to Learnsignal! Pass Your #{course_log.course&.group&.name}  Exams First Time", course: course_log.course.group.name, next_step: next_step.name,
                                                                                                                                          url: UrlHelper.instance.show_course_url(
                                                                                                                                                                                course_name_url: next_step.course_lesson.course_section.course.name_url,
                                                                                                                                                                                course_section_name_url: next_step.course_lesson.course_section.name_url,
                                                                                                                                                                                course_lesson_name_url: next_step.course_lesson.name_url,
                                                                                                                                                                                course_step_name_url: next_step.name_url, host: LEARNSIGNAL_HOST,
                                                                                                                                                                                utm_campaign: 'OnboardingEmails', utm_content: 'send_onboarding_content_email')
                                                                                                                                        })
    end
  end

  protected

  def create_workers
    6.times { |i| OnboardingEmailWorker.perform_at((i + 1).day, id, i + 1) }
  end

  def update_hubspot
    # Custom property values -> [Not Active - Active - Completed]
    # Trigger HubSpot - set property to Active
  end
end
