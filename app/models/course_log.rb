# frozen_string_literal: true

# == Schema Information
#
# Table name: course_logs
#
#  id                                   :integer          not null, primary key
#  user_id                              :integer
#  session_guid                         :string
#  course_id                            :integer
#  percentage_complete                  :integer          default("0")
#  count_of_cmes_completed              :integer          default("0")
#  latest_course_step_id                :integer
#  completed                            :boolean          default("false")
#  created_at                           :datetime         not null
#  updated_at                           :datetime         not null
#  count_of_questions_correct           :integer
#  count_of_questions_taken             :integer
#  count_of_videos_taken                :integer
#  count_of_quizzes_taken               :integer
#  completed_at                         :datetime
#  count_of_constructed_responses_taken :integer
#  count_of_notes_completed             :integer
#

class CourseLog < ApplicationRecord
  belongs_to :user
  belongs_to :course
  belongs_to :latest_course_step, class_name: 'CourseStep', foreign_key: :latest_course_step_id, optional: true
  has_many :enrollments
  has_many :course_section_logs
  has_many :course_lesson_logs
  has_many :course_step_logs

  validates :user_id, presence: true
  validates :course_id, presence: true
  validates :percentage_complete, presence: true

  delegate :name, to: :user, prefix: :user
  delegate :email, to: :user, prefix: :user
  delegate :completion_cme_count, to: :course

  # callbacks
  before_destroy :check_dependencies
  after_save :update_enrollment
  after_save :emit_certificate, if: :saved_change_to_completed?
  after_create :create_onboarding_process

  # scopes
  scope :all_in_order, -> { order(:user_id, :created_at) }
  scope :all_complete, -> { where('percentage_complete > 99') }
  scope :all_incomplete, -> { where('percentage_complete < 100') }
  scope :for_user, ->(user_id) { where(user_id: user_id) }
  scope :for_course, ->(course_id) { where(course_id: course_id) }

  # class methods
  def self.to_csv(options = {})
    attributes = %w[id user_id user_email f_name l_name enrolled enrollment_sitting exam_date
                    student_number date_of_birth completed percentage_complete
                    count_of_cmes_completed completion_cme_count]

    CSV.generate(options) do |csv|
      csv << attributes

      find_each do |scul|
        csv << attributes.map { |attr| scul.send(attr) }
      end
    end
  end

  # instance methods
  def destroyable?
    course_section_logs.empty? && course_lesson_logs.empty?
  end

  def elements_total_for_completion
    course.completion_cme_count
  end

  def active_enrollment
    enrollments.where(active: true).last
  end

  def recalculate_scul_completeness
    self.count_of_videos_taken                = course_section_logs.with_valid_course_section.sum(:count_of_videos_taken)
    self.count_of_quizzes_taken               = course_section_logs.with_valid_course_section.sum(:count_of_quizzes_taken)
    self.count_of_notes_completed             = course_section_logs.with_valid_course_section.sum(:count_of_notes_taken)
    self.count_of_constructed_responses_taken = course_section_logs.with_valid_course_section.sum(:count_of_constructed_responses_taken)
    self.count_of_cmes_completed              = course_section_logs.with_valid_course_section.sum(:count_of_cmes_completed)

    self.percentage_complete = (count_of_cmes_completed / elements_total_for_completion.to_f) * 100 if elements_total_for_completion.positive?

    self.completed = true if percentage_complete > 99 && percentage_complete.present?

    save!
  end

  def f_name
    user.first_name
  end

  def l_name
    user.last_name
  end

  def date_of_birth
    user.try(:date_of_birth)
  end

  def enrolled
    true if active_enrollment
  end

  def exam_date
    active_enrollment.enrollment_date if enrolled
  end

  def enrollment_sitting
    enrollments.last.try(:exam_date) if enrolled
  end

  def student_number
    user.exam_body_user_details.for_exam_body(course.exam_body_id).first.try(:student_number)
  end

  protected

  def check_dependencies
    return if destroyable?

    errors.add(:base, I18n.t('models.general.dependencies_exist'))
    false
  end

  def update_enrollment
    return if active_enrollment.nil? || active_enrollment&.expired

    active_enrollment.update_attribute(:percentage_complete, percentage_complete)
    update_attribute(:completed_at, proc { Time.zone.now }.call) if completed && !completed_at
  end

  def emit_certificate
    return unless course.emit_certificate? && completed

    CourseLogsWorker.perform_async(user_name, user_email, course.accredible_group_id)
  end

  def create_onboarding_process
    if course&.exam_body&.has_sittings &&
       user&.standard_student_user? &&
       user&.course_logs&.count <= 1 &&
       course_step_logs.count >= 1 &&
       !user&.viewable_subscriptions&.any? &&
       !user&.onboarding_process

      OnboardingProcess.create(user_id: user_id, course_log_id: id)
    end
  end
end
