# == Schema Information
#
# Table name: course_section_user_logs
#
#  id                                   :integer          not null, primary key
#  user_id                              :integer
#  course_section_id                    :integer
#  subject_course_user_log_id           :integer
#  latest_course_module_element_id      :integer
#  percentage_complete                  :float
#  count_of_cmes_completed              :integer
#  count_of_quizzes_taken               :integer
#  count_of_videos_taken                :integer
#  created_at                           :datetime         not null
#  updated_at                           :datetime         not null
#  subject_course_id                    :integer
#  count_of_constructed_responses_taken :integer
#

class CourseSectionUserLog < ActiveRecord::Base


  include LearnSignalModelExtras

  # Constants

  # relationships
  belongs_to :user
  belongs_to :subject_course
  belongs_to :subject_course_user_log
  belongs_to :course_section
  has_many :student_exam_tracks
  has_many :course_module_element_user_logs

  # validation
  validates :user_id, presence: true
  validates :course_section_id, presence: true
  validates :subject_course_user_log_id, presence: true

  # callbacks
  before_validation :create_subject_course_user_log, unless: :subject_course_user_log_id
  after_save :update_subject_course_user_log


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
    self.student_exam_tracks.empty? && self.course_module_element_user_logs.empty?
  end

  def elements_total
    self.course_section.try(:cme_count) || 0
  end

  def completed?
    self.percentage_complete && self.percentage_complete > 99
  end

  def recalculate_completeness
    #Called only from the StudentExamTrack after_save
    self.count_of_videos_taken = self.student_exam_tracks.with_valid_course_module.sum(:count_of_videos_taken)
    self.count_of_quizzes_taken = self.student_exam_tracks.with_valid_course_module.sum(:count_of_quizzes_taken)
    self.count_of_constructed_responses_taken = self.student_exam_tracks.with_valid_course_module.sum(:count_of_constructed_responses_taken)
    self.count_of_cmes_completed = self.student_exam_tracks.with_valid_course_module.sum(:count_of_cmes_completed)
    self.percentage_complete = (self.count_of_cmes_completed.to_f / self.elements_total.to_f) * 100.0
    self.save!
  end

  protected

  def create_subject_course_user_log
    scul = SubjectCourseUserLog.create!(user_id: self.user_id, subject_course_id: self.subject_course_id)
    self.subject_course_user_log_id = scul.id
  end

  # After Save
  def update_subject_course_user_log
    scul = self.subject_course_user_log
    scul.latest_course_module_element_id = self.latest_course_module_element_id if self.latest_course_module_element_id
    scul.recalculate_completeness # Includes a save!
  end

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

end
