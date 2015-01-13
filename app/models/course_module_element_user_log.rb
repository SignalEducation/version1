# == Schema Information
#
# Table name: course_module_element_user_logs
#
#  id                          :integer          not null, primary key
#  course_module_element_id    :integer
#  user_id                     :integer
#  session_guid                :string(255)
#  element_completed           :boolean          default(FALSE), not null
#  time_taken_in_seconds       :integer
#  quiz_score_actual           :integer
#  quiz_score_potential        :integer
#  is_video                    :boolean          default(FALSE), not null
#  is_quiz                     :boolean          default(FALSE), not null
#  course_module_id            :integer
#  latest_attempt              :boolean          default(TRUE), not null
#  corporate_customer_id       :integer
#  created_at                  :datetime
#  updated_at                  :datetime
#  course_module_jumbo_quiz_id :integer
#  is_jumbo_quiz               :boolean          default(FALSE), not null
#

class CourseModuleElementUserLog < ActiveRecord::Base

  include LearnSignalModelExtras

  # attr-accessible
  attr_accessible :course_module_element_id, :user_id, :session_guid,
                  :element_completed, :time_taken_in_seconds,
                  :quiz_score_actual, :quiz_score_potential,
                  :is_video, :is_quiz, :is_jumbo_quiz, :course_module_id,
                  :corporate_customer_id, :course_module_jumbo_quiz_id,
                  :quiz_attempts_attributes

  # Constants

  # relationships
  belongs_to :corporate_customer
  belongs_to :course_module
  belongs_to :course_module_element
  belongs_to :course_module_jumbo_quiz
  has_many   :quiz_attempts, inverse_of: :course_module_element_user_log
  belongs_to :user
  accepts_nested_attributes_for :quiz_attempts

  # validation
  validates :course_module_element_id, allow_nil: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :course_module_jumbo_quiz_id, allow_nil: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :user_id, allow_nil: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :session_guid, presence: true
  validates :time_taken_in_seconds, presence: true
  validates :course_module_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :corporate_customer_id, allow_nil: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :quiz_score_actual, presence: true, if: 'is_quiz == true', on: :update
  validates :quiz_score_potential, presence: true, if: 'is_quiz == true', on: :update

  # callbacks
  before_create :set_latest_attempt
  before_create :set_booleans
  after_create :calculate_score
  after_create :create_or_update_student_exam_track

  # scopes
  scope :all_in_order, -> { order(:course_module_element_id) }
  scope :for_session_guid, lambda { |the_guid| where(session_guid: the_guid) }
  scope :for_unknown_users, -> { where(user_id: nil) }
  scope :for_course_module, lambda { |module_id| where(course_module_id: module_id) }
  scope :for_course_module_element, lambda { |element_id| where(course_module_element_id: element_id) }
  scope :for_jumbo_quiz, lambda { |element_id| where(course_module_jumbo_quiz_id: element_id) }
  scope :latest_only, -> { where(latest_attempt: true) }
  scope :quizzes, -> { where(is_quiz: true) }
  scope :videos, -> { where(is_video: true) }
  scope :jumbo_quizzes, -> { where(is_jumbo_quiz: true) }

  # class methods
  def self.assign_user_to_session_guid(the_user_id, the_session_guid)
    # activate this with the following:
    # CourseModuleElementUserLog.assign_user_to_session_guid(123, 'abcde123')
    CourseModuleElementUserLog.for_session_guid(the_session_guid).for_unknown_users.update_all(user_id: the_user_id)
  end

  def self.for_user_or_session(the_user_id, the_session_guid)
    if the_user_id
      where(user_id: the_user_id)
    else
      where(session_guid: the_session_guid)
    end
  end

  # instance methods
  def destroyable?
    self.quiz_attempts.empty?
  end

  def recent_attempts
    self.user_id ?
            CourseModuleElementUserLog.where(user_id: self.user_id, course_module_element_id: self.course_module_element_id, course_module_jumbo_quiz_id: self.course_module_jumbo_quiz_id, latest_attempt: false).order(created_at: :desc).limit(5) :
            CourseModuleElementUserLog.where(session_guid: self.session_guid, course_module_element_id: self.course_module_element_id, course_module_jumbo_quiz_id: self.course_module_jumbo_quiz_id, latest_attempt: false).order(created_at: :desc).limit(5)
  end

  protected

  def calculate_score
    self.quiz_score_actual = self.quiz_attempts.sum(:score)
    if self.is_quiz
      self.quiz_score_potential = self.recent_attempts.count == 0 ?
          self.course_module_element.course_module_element_quiz.best_possible_score_first_attempt :
          self.course_module_element.course_module_element_quiz.best_possible_score_retry
    elsif self.is_jumbo_quiz
      self.quiz_score_potential = self.recent_attempts.count == 0 ?
          self.course_module_jumbo_quiz.best_possible_score_first_attempt :
          self.course_module_jumbo_quiz.best_possible_score_retry
    end
    self.save(callbacks: false, validate: false)
  end

  def create_or_update_student_exam_track
    set = StudentExamTrack.where(user_id: self.user_id, session_guid: self.session_guid, course_module_id: self.course_module_id).first_or_initialize
    set.exam_level_id ||= self.course_module.exam_level_id
    set.exam_section_id ||= self.course_module.exam_section_id
    set.latest_course_module_element_id = self.course_module_element_id
    set.jumbo_quiz_taken = true if self.is_jumbo_quiz
    set.save!
  end

  def set_booleans
    if self.course_module_jumbo_quiz
      self.is_jumbo_quiz = true
    elsif self.course_module_element.course_module_element_quiz
      self.is_quiz = true
    else
      self.is_video = true
    end
    true
  end

  def set_latest_attempt
    self.latest_attempt = true
    others = CourseModuleElementUserLog.for_user_or_session(self.user_id, self.session_guid).where(course_module_element_id: self.course_module_element_id, course_module_jumbo_quiz_id: self.course_module_jumbo_quiz_id).latest_only
    others.update_all(latest_attempt: false)
    true
  end

end
