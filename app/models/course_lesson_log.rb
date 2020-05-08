# == Schema Information
#
# Table name: course_lesson_logs
#
#  id                                   :integer          not null, primary key
#  user_id                              :integer
#  latest_course_step_id      :integer
#  created_at                           :datetime
#  updated_at                           :datetime
#  session_guid                         :string(255)
#  course_lesson_id                     :integer
#  percentage_complete                  :float            default("0")
#  count_of_cmes_completed              :integer          default("0")
#  course_id                    :integer
#  count_of_questions_taken             :integer
#  count_of_questions_correct           :integer
#  count_of_quizzes_taken               :integer
#  count_of_videos_taken                :integer
#  course_log_id           :integer
#  count_of_constructed_responses_taken :integer
#  course_section_id                    :integer
#  course_section_log_id           :integer
#

#This should have been called CourseLessonUserLog
class CourseLessonLog < ApplicationRecord

  include LearnSignalModelExtras

  # Constants

  # relationships
  belongs_to :user, optional: true
  belongs_to :course, optional: true
  belongs_to :course_log, optional: true
  belongs_to :course_section, optional: true
  belongs_to :course_section_log, optional: true
  belongs_to :course_lesson, optional: true
  belongs_to :latest_course_step, class_name: 'CourseStep',
             foreign_key: :latest_course_step_id, optional: true
  has_many :course_step_logs

  # validation
  validates :user_id, presence: true
  validates :course_id, presence: true
  validates :course_lesson_id, presence: true
  validates :course_section_log_id, presence: true
  validates :course_section_id, presence: true
  validates :course_log_id, presence: true

  # callbacks
  before_validation :create_course_section_log, unless: :course_section_log_id
  after_update :update_course_section_log

  # scopes
  scope :all_in_order, -> { order(user_id: :asc, updated_at: :desc) }
  scope :for_user, lambda { |user_id| where(user_id: user_id) }
  scope :for_course_lesson, lambda { |cm_id| where(course_lesson_id: cm_id) }
  scope :for_user_and_module, lambda { |cm_id, user_id| where(course_lesson_id: cm_id, user_id: user_id) }
  scope :with_active_cmes, -> { includes(:course_lesson).where('course_lessons.active = ?', true).where('course_lessons.cme_count > 0').references(:course_lesson) }
  scope :with_valid_course_lesson, -> { includes(:course_lesson).where('course_lessons.active = ?', true).where('course_lessons.test = ?', false).where('course_lessons.cme_count > 0').references(:course_lesson) }
  scope :all_complete, -> { where('percentage_complete > 99') }
  scope :all_incomplete, -> { where('percentage_complete < 100') }

  # class methods

  # instance methods

  def cme_user_logs
    self.course_step_logs.with_elements_active
  end

  def completed_cme_user_logs
    cme_user_logs.all_completed
  end

  def destroyable?
    self.course_step_logs.empty?
  end

  def elements_total
    self.course_lesson.cme_count
  end

  def elements_complete
    self.latest_cme_user_logs.all_completed.with_elements_active.count
  end

  def latest_cme_user_logs
    self.course_step_logs.latest_only
  end

  def unique_logs
    self.course_step_logs.all_completed.with_elements_active.map(&:course_step_id).uniq
  end

  def enrollment
    self.course_log.active_enrollment
  end

  def recalculate_set_completeness
    #Called from the CourseStepLog after_save or the CourseLogWorker
    unique_video_ids = completed_cme_user_logs.where(is_video: true).map(&:course_step_id).uniq
    unique_quiz_ids = completed_cme_user_logs.where(is_quiz: true).map(&:course_step_id).uniq
    unique_constructed_response_ids = completed_cme_user_logs.where(is_constructed_response: true).map(&:course_step_id).uniq
    self.count_of_videos_taken = unique_video_ids.count
    self.count_of_quizzes_taken = unique_quiz_ids.count
    self.count_of_constructed_responses_taken = unique_constructed_response_ids.count
    self.count_of_cmes_completed = (unique_video_ids.count + unique_quiz_ids.count + unique_constructed_response_ids.count)
    self.percentage_complete = (self.count_of_cmes_completed.to_f / self.elements_total.to_f) * 100.0
    self.save!
  end


  protected

  # Before Validation
  def create_course_section_log
    csul = CourseSectionLog.create!(user_id: self.user_id, course_section_id: self.course_section_id,
                                        course_id: self.course_lesson.course_id,
                                        course_log_id: self.try(:course_log_id))
    self.course_section_log_id = csul.id
    self.course_log_id = csul.course_log_id
  end

  # After Save
  def update_course_section_log
    course_section_log.latest_course_step_id = latest_course_step_id
    course_section_log.recalculate_csul_completeness # Includes a save!
  end

end
