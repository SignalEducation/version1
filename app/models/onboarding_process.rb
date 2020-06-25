# frozen_string_literal: true

# == Schema Information
#
# Table name: onboarding_processes
#
#  id                   :bigint           not null, primary key
#  user_id              :integer
#  course_log_id        :integer
#  active               :boolean          default("true"), not null
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#  course_lesson_log_id :integer
#

class OnboardingProcess < ApplicationRecord
  belongs_to :user
  belongs_to :course_log, optional: true
  belongs_to :course_lesson_log, optional: true
  has_many :messages, dependent: :destroy

  validates :user_id, presence: true

  after_create :create_workers
  after_save   :update_hubspot

  def content_remaining?
    if course_lesson_log
      !course_lesson_log.completed?
    else
      free_step_ids           = course_log&.course&.free_course_steps&.map(&:id)&.sort
      completed_log_step_ids  = course_log&.course_step_logs&.all_completed&.map(&:course_step_id)&.sort

      free_step_ids != completed_log_step_ids
    end
  end

  def next_step
    if course_lesson_log&.next_step
      course_lesson_log&.next_step
    elsif course_log&.latest_course_step&.next_element
      course_log&.latest_course_step&.next_element
    elsif course_log&.course_step_logs
      course_log.course_step_logs.where(latest_attempt: true, element_completed: false).order(:created_at)&.last&.course_step
    else
      course_log&.course&.free_course_steps&.first
    end
  end

  def onboarding_subject(day)
    case day
    when 1
      "Continue your #{exam_body.group.name} study today. See what’s next!"
    when 2
      "Pass your #{exam_body.group.name} Exams first time. Get Ahead Now!"
    when 3
      "#{exam_body.group.name} Exams: Keep the momentum going & complete a #{next_step&.name} today!"
    when 4
      "What’s next?  Try this #{exam_body.group.name} #{next_step&.name}!"
    when 5
      "#{exam_body.group.name} Exams: Here’s what to study today!"
    else
      'Continue your study today. See what’s next!'
    end
  end

  def send_email(day)
    if day == 6
      Message.create(process_at: Time.zone.now, user_id: user_id, kind: :onboarding, template: 'send_onboarding_expired_email', onboarding_process_id: id, template_params: { course: exam_body.group.name,
                                                                                                                                                  url: UrlHelper.instance.new_subscription_url(exam_body_id: exam_body.id, host: LEARNSIGNAL_HOST, utm_medium: 'email', utm_campaign: 'OnboardingEmails', utm_content: 'send_onboarding_expired_email', utm_source: "Onboarding-#{id}", utm_term: "Day-#{day}") })
      update(active: false)
    elsif !content_remaining?
      Message.create(process_at: Time.zone.now, user_id: user_id, kind: :onboarding, template: 'send_onboarding_complete_email', onboarding_process_id: id, template_params: { course: exam_body.group.name,
                                                                                                                                           url: UrlHelper.instance.new_subscription_url(exam_body_id: exam_body.id, host: LEARNSIGNAL_HOST, utm_medium: 'email', utm_campaign: 'OnboardingEmails', utm_content: 'send_onboarding_complete_email', utm_source: "Onboarding-#{id}", utm_term: "Day-#{day}") })
      update(active: false)
    elsif next_step
      Message.create(process_at: Time.zone.now, user_id: user_id, kind: :onboarding, template: 'send_onboarding_content_email', onboarding_process_id: id, template_params: { day: day,
                                                                                                                                                   subject_line: onboarding_subject(day),
                                                                                                                                                   course_name: exam_body&.group&.name,
                                                                                                                                                   next_step_name: next_step&.name,
                                                                                                                                                   url: next_step_url(day)
                                                                                                                                        })
    end
  end

  def exam_body
    if course_lesson_log_id
      course_lesson_log.course.exam_body
    else
      course_log.course.exam_body
    end
  end

  def course
    if course_lesson_log_id
      course_lesson_log.course
    else
      course_log.course
    end
  end

  def course_name
    course.name
  end

  def message_count
    messages.count
  end

  def started_step_count
    course_lesson_log.course_step_logs.all.pluck(:course_step_id).uniq.count
  end

  def completed_step_count
    course_lesson_log.course_step_logs.all_completed.pluck(:course_step_id).uniq.count
  end

  def message_complete
    messages.find_by(template: 'send_onboarding_complete_email', state: 'sent') ? messages.find_by(template: 'send_onboarding_complete_email', state: 'sent').process_at : ''
  end

  def message_expired
    messages.find_by(template: 'send_onboarding_expired_email', state: 'sent') ? messages.find_by(template: 'send_onboarding_expired_email', state: 'sent').process_at : ''
  end

  def content_complete
    course_lesson_log.percentage_complete
  end

  def loaded_payment_page
    if started_step_count >= 5
      user.ahoy_events.all_checkout_events.where('ahoy_events.time > ? AND ahoy_events.time < ?', created_at.beginning_of_month, created_at.end_of_month).count
    else
      0
    end
  end

  def paid_that_month
    if started_step_count >= 5 && loaded_payment_page >= 1
      user.ahoy_events.all_payment_success_events.where('ahoy_events.time > ? AND ahoy_events.time < ?', created_at.beginning_of_month, created_at.end_of_month).any?
    else
      0
    end
  end

  def get_started_next_event
    user.ahoy_events.all_get_started_events.where('ahoy_events.time > ? AND ahoy_events.time < ?', ob.created_at.beginning_of_month, ob.created_at.end_of_month)&.first&.next_event&.name
  end

  def self.to_csv(options = {}, attributes = %w[id user_id created_at exam_body course_name message_count content_complete started_step_count completed_step_count message_complete message_expired paid_that_month loaded_payment_page get_started_next_event])
    CSV.generate(options) do |csv|
      csv << attributes

      find_each do |user|
        csv << attributes.map { |attr| user.send(attr) }
      end
    end
  end

  protected

  def create_workers
    6.times { |i| OnboardingEmailWorker.perform_at((i + 1).day, id, i + 1) }
  end

  def next_step_url(day)
    if next_step && next_step.class.name == 'CourseStep'
      UrlHelper.instance.show_course_url(course_name_url: next_step.course_lesson.course_section.course.name_url, course_section_name_url: next_step.course_lesson.course_section.name_url, course_lesson_name_url: next_step.course_lesson.name_url, course_step_name_url: next_step.name_url, host: LEARNSIGNAL_HOST, utm_campaign: 'OnboardingEmails', utm_content: 'send_onboarding_content_email', utm_source: "Onboarding-#{id}", utm_term: "Day-#{day}")
    else
      UrlHelper.instance.library_course_url(group_name_url: course.group.name_url, course_name_url: course.name_url, host: LEARNSIGNAL_HOST, utm_medium: 'email', utm_campaign: 'OnboardingEmails', utm_content: 'send_onboarding_content_email', utm_source: "Onboarding-#{id}", utm_term: "Day-#{day}")
    end
  end

  def update_hubspot
    HubSpot::Contacts.new.batch_create(user_id, { property: 'onboarding_process', value: user.onboarding_state }) unless Rails.env.test?
  end
end
