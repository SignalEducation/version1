# == Schema Information
#
# Table name: course_section_logs
#
#  id                                   :integer          not null, primary key
#  user_id                              :integer
#  course_section_id                    :integer
#  course_log_id                        :integer
#  latest_course_step_id                :integer
#  percentage_complete                  :float
#  count_of_cmes_completed              :integer
#  count_of_quizzes_taken               :integer
#  count_of_videos_taken                :integer
#  created_at                           :datetime         not null
#  updated_at                           :datetime         not null
#  course_id                            :integer
#  count_of_constructed_responses_taken :integer
#  count_of_notes_taken                 :integer
#

class CourseSectionLog < ApplicationRecord
  include LearnSignalModelExtras

  # Constants

  # relationships
  belongs_to :user, optional: true
  belongs_to :course, optional: true
  belongs_to :course_log, optional: true
  belongs_to :course_section, optional: true
  has_many :course_lesson_logs
  has_many :course_step_logs

  # validation
  validates :user_id, presence: true
  validates :course_section_id, presence: true
  validates :course_log_id, presence: true
  validates :course_id, presence: true

  # callbacks
  before_validation :create_course_log, unless: :course_log_id
  after_update :update_course_log

  # scopes
  scope :all_in_order, -> { order(:user_id) }
  scope :for_user, lambda { |user_id| where(user_id: user_id) }
  scope :for_course_section, lambda { |cs_id| where(course_section_id: cs_id) }
  scope :for_user_and_section, lambda { |cs_id, user_id| where(course_section_id: cs_id, user_id: user_id) }
  scope :all_complete, -> { where('percentage_complete > 99') }
  scope :all_incomplete, -> { where('percentage_complete < 100') }
  scope :with_valid_course_section, -> do  includes(:course_section).where(
      'course_sections.active = ?', true).where(
      'course_sections.counts_towards_completion = ?', true).where(
      'course_sections.cme_count > 0').references(:course_section)
  end

  # class methods

  # instance methods
  def destroyable?
    self.course_lesson_logs.empty? && self.course_step_logs.empty?
  end

  def elements_total
    self.course_section.try(:cme_count) || 0
  end

  def completed?
    self.percentage_complete && self.percentage_complete > 99
  end

  def recalculate_csul_completeness
    self.count_of_videos_taken                = course_lesson_logs.with_valid_course_lesson.sum(:count_of_videos_taken)
    self.count_of_quizzes_taken               = course_lesson_logs.with_valid_course_lesson.sum(:count_of_quizzes_taken)
    self.count_of_notes_taken                 = course_lesson_logs.with_valid_course_lesson.sum(:count_of_notes_taken)
    self.count_of_practice_questions_taken    = course_lesson_logs.with_valid_course_lesson.sum(:count_of_practice_questions_taken)
    self.count_of_constructed_responses_taken = course_lesson_logs.with_valid_course_lesson.sum(:count_of_constructed_responses_taken)
    self.count_of_cmes_completed              = course_lesson_logs.with_valid_course_lesson.sum(:count_of_cmes_completed)
    self.percentage_complete                  = (count_of_cmes_completed / elements_total.to_f) * 100.0
    self.save!
  end

  protected

  def create_course_log
    scul = CourseLog.create!(user_id: self.user_id, course_id: self.course_id)
    self.course_log_id = scul.id
  end

  # After Save
  def update_course_log
    course_log.latest_course_step_id = latest_course_step_id
    course_log.recalculate_scul_completeness # Includes a save!
  end

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end
end
