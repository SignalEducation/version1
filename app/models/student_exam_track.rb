# == Schema Information
#
# Table name: student_exam_tracks
#
#  id                                   :integer          not null, primary key
#  user_id                              :integer
#  latest_course_module_element_id      :integer
#  created_at                           :datetime
#  updated_at                           :datetime
#  session_guid                         :string
#  course_module_id                     :integer
#  percentage_complete                  :float            default(0.0)
#  count_of_cmes_completed              :integer          default(0)
#  subject_course_id                    :integer
#  count_of_questions_taken             :integer
#  count_of_questions_correct           :integer
#  count_of_quizzes_taken               :integer
#  count_of_videos_taken                :integer
#  subject_course_user_log_id           :integer
#  count_of_constructed_responses_taken :integer
#  course_section_id                    :integer
#  course_section_user_log_id           :integer
#

#This should have been called CourseModuleUserLog
class StudentExamTrack < ApplicationRecord

  include LearnSignalModelExtras

  # Constants

  # relationships
  belongs_to :user, optional: true
  belongs_to :subject_course, optional: true
  belongs_to :subject_course_user_log, optional: true
  belongs_to :course_section, optional: true
  belongs_to :course_section_user_log, optional: true
  belongs_to :course_module, optional: true
  belongs_to :latest_course_module_element, class_name: 'CourseModuleElement',
             foreign_key: :latest_course_module_element_id, optional: true
  has_many :course_module_element_user_logs

  # validation
  validates :user_id, presence: true
  validates :subject_course_id, presence: true
  validates :course_module_id, presence: true
  validates :course_section_user_log_id, presence: true
  validates :course_section_id, presence: true
  validates :subject_course_user_log_id, presence: true

  # callbacks
  before_validation :create_course_section_user_log, unless: :course_section_user_log_id
  after_update :update_course_section_user_log

  # scopes
  scope :all_in_order, -> { order(user_id: :asc, updated_at: :desc) }
  scope :for_user, lambda { |user_id| where(user_id: user_id) }
  scope :for_course_module, lambda { |cm_id| where(course_module_id: cm_id) }
  scope :for_user_and_module, lambda { |cm_id, user_id| where(course_module_id: cm_id, user_id: user_id) }
  scope :with_active_cmes, -> { includes(:course_module).where('course_modules.active = ?', true).where('course_modules.cme_count > 0').references(:course_module) }
  scope :with_valid_course_module, -> { includes(:course_module).where('course_modules.active = ?', true).where('course_modules.test = ?', false).where('course_modules.cme_count > 0').references(:course_module) }
  scope :all_complete, -> { where('percentage_complete > 99') }
  scope :all_incomplete, -> { where('percentage_complete < 100') }

  # class methods

  # instance methods

  def cme_user_logs
    self.course_module_element_user_logs.with_elements_active
  end

  def completed_cme_user_logs
    cme_user_logs.all_completed
  end

  def destroyable?
    self.course_module_element_user_logs.empty?
  end

  def elements_total
    self.course_module.cme_count
  end

  def elements_complete
    self.latest_cme_user_logs.all_completed.with_elements_active.count
  end

  def latest_cme_user_logs
    self.course_module_element_user_logs.latest_only
  end

  def unique_logs
    self.course_module_element_user_logs.all_completed.with_elements_active.map(&:course_module_element_id).uniq
  end

  def enrollment
    self.subject_course_user_log.active_enrollment
  end

  def recalculate_set_completeness
    #Called from the CourseModuleElementUserLog after_save or the SubjectCourseUserLogWorker
    unique_video_ids = completed_cme_user_logs.where(is_video: true).map(&:course_module_element_id).uniq
    unique_quiz_ids = completed_cme_user_logs.where(is_quiz: true).map(&:course_module_element_id).uniq
    unique_constructed_response_ids = completed_cme_user_logs.where(is_constructed_response: true).map(&:course_module_element_id).uniq
    self.count_of_videos_taken = unique_video_ids.count
    self.count_of_quizzes_taken = unique_quiz_ids.count
    self.count_of_constructed_responses_taken = unique_constructed_response_ids.count
    self.count_of_cmes_completed = (unique_video_ids.count + unique_quiz_ids.count + unique_constructed_response_ids.count)
    self.percentage_complete = (self.count_of_cmes_completed.to_f / self.elements_total.to_f) * 100.0
    self.save!
  end


  protected

  # Before Validation
  def create_course_section_user_log
    return if Rails.env.test?

    csul = CourseSectionUserLog.create!(user_id: self.user_id, course_section_id: self.course_section_id,
                                        subject_course_id: self.course_module.subject_course_id,
                                        subject_course_user_log_id: self.try(:subject_course_user_log_id))
    self.course_section_user_log_id = csul.id
    self.subject_course_user_log_id = csul.subject_course_user_log_id
  end

  # After Save
  def update_course_section_user_log
    course_section_user_log.recalculate_csul_completeness # Includes a save!
  end

end
