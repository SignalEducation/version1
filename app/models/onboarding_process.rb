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
  after_save   :update_hubspot

  def content_remaining?
    free_step_ids           = course_log.course.free_course_steps.map(&:id).sort
    completed_log_step_ids  = course_log.course_step_logs.all_completed.map(&:course_step_id).sort

    free_step_ids != completed_log_step_ids
  end

  def next_step
    if course_log.latest_course_step
      course_log.latest_course_step.next_free_step
    else
      course_log.course_step_logs.where(latest_attempt: true, element_completed: false).order(:created_at)&.last&.course_step
    end
  end

  def onboarding_subject(day)
    case day
    when 1
      "Continue your #{course_log.course.group.name} study today. See what’s next!"
    when 2
      "Pass your #{course_log.course.group.name} Exams first time. Get Ahead Now!"
    when 3
      "#{course_log.course.group.name} Exams: Keep the momentum going & complete a #{next_step&.name} today!"
    when 4
      "What’s next?  Try this #{course_log.course.group.name} #{next_step&.name}!"
    when 5
      "#{course_log.course.group.name} Exams: Here’s what to study today!"
    else
      'Continue your study today. See what’s next!'
    end
  end

  def send_email(day)
    if day == 6
      Message.create(process_at: Time.zone.now, user_id: user_id, kind: :onboarding, template: 'send_onboarding_expired_email', template_params: { course: course_log.course.group.name,
                                                                                                                                                  url: UrlHelper.instance.new_subscription_url(exam_body_id: course_log.course.exam_body_id, host: LEARNSIGNAL_HOST, utm_campaign: 'OnboardingEmails', utm_content: 'send_onboarding_expired_email') })
      update(active: false)
    elsif !content_remaining?
      Message.create(process_at: Time.zone.now, user_id: user_id, kind: :onboarding, template: 'send_onboarding_complete_email', template_params: { course: course_log.course.group.name,
                                                                                                                                           url: UrlHelper.instance.new_subscription_url(exam_body_id: course_log.course.exam_body_id, host: LEARNSIGNAL_HOST, utm_campaign: 'OnboardingEmails', utm_content: 'send_onboarding_complete_email') })
      update(active: false)
    elsif next_step
      Message.create(process_at: Time.zone.now, user_id: user_id, kind: :onboarding, template: 'send_onboarding_content_email', template_params: { day: day,
                                                                                                                                                   subject_line: onboarding_subject(day),
                                                                                                                                                   course_name: course_log.course&.group&.name,
                                                                                                                                                   next_step_name: next_step&.name,
                                                                                                                                                   url: next_step_url
                                                                                                                                        })
    end
  end

  protected

  def create_workers
    6.times { |i| OnboardingEmailWorker.perform_at((i + 1).day, id, i + 1) }
  end

  def next_step_url
    if next_step
      UrlHelper.instance.show_course_url(course_name_url: next_step.course_lesson.course_section.course.name_url, course_section_name_url: next_step.course_lesson.course_section.name_url, course_lesson_name_url: next_step.course_lesson.name_url, course_step_name_url: next_step.name_url, host: LEARNSIGNAL_HOST, utm_campaign: 'OnboardingEmails', utm_content: 'send_onboarding_content_email')
    else
      UrlHelper.instance.library_course_url(course_log.course.parent.name_url, course_log.course.name_url, host: LEARNSIGNAL_HOST, utm_campaign: 'OnboardingEmails', utm_content: 'send_onboarding_content_email')
    end
  end

  def update_hubspot
    return if Rails.env.test?

    HubSpot::Contacts.new.batch_create(user_id, { property: 'onboarding_process', value: user.onboarding_state })
  end
end
