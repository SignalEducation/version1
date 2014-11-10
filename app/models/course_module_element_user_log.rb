# == Schema Information
#
# Table name: course_module_element_user_logs
#
#  id                       :integer          not null, primary key
#  course_module_element_id :integer
#  user_id                  :integer
#  session_guid             :string(255)
#  element_completed        :boolean          default(FALSE), not null
#  time_taken_in_seconds    :integer
#  quiz_score_actual        :integer
#  quiz_score_potential     :integer
#  is_video                 :boolean          default(FALSE), not null
#  is_quiz                  :boolean          default(FALSE), not null
#  course_module_id         :integer
#  latest_attempt           :boolean          default(TRUE), not null
#  corporate_customer_id    :integer
#  created_at               :datetime
#  updated_at               :datetime
#

class CourseModuleElementUserLog < ActiveRecord::Base

  # attr-accessible
  attr_accessible :course_module_element_id, :user_id, :session_guid,
                  :element_completed, :time_taken_in_seconds, :quiz_score_actual,
                  :quiz_score_potential, :is_video, :is_quiz, :course_module_id,
                  :corporate_customer_id

  # Constants

  # relationships
  belongs_to :course_module_element
  belongs_to :user
  belongs_to :course_module
  # todo belongs_to :corporate_customer
  # todo has_many :quiz_attempts

  # validation
  validates :course_module_element_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :user_id, allow_nil: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :session_guid, presence: true
  validates :time_taken_in_seconds, presence: true
  validates :quiz_score_actual, presence: true
  validates :quiz_score_potential, presence: true
  validates :course_module_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :corporate_customer_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :quiz_score_actual, presence: true, if: 'course_module_element.try(:course_module_element_quiz_id).to_i > 0'
  validates :quiz_score_potential, presence: true, if: 'course_module_element.try(:course_module_element_quiz_id).to_i > 0'

  # callbacks
  before_destroy :check_dependencies
  before_create :set_latest_attempt
  after_create :mark_previous_attempts_as_latest_false

  # scopes
  scope :all_in_order, -> { order(:course_module_element_id) }
  scope :for_session_guid, lambda { |the_session_id| where(session_guid:
                                                               the_session_id) }
  scope :for_unknown_users, -> { where(user_id: nil) }
  scope :for_course_module, lambda { |module_id| where(course_module_id: module_id) }
  scope :for_course_module_element, lambda { |element_id| where(course_module_element_id: element_id) }
  scope :latest_only, -> { where(latest_attempt: true) }
  scope :quizzes, -> { where(is_quiz: true) }
  scope :videos, -> { where(is_video: true) }

  def for_user_or_session(the_user_id, the_session_guid)
    if the_user_id
      where(user_id: the_user_id)
    else
      where(session_guid: the_session_guid)
    end
  end

  # class methods

  # instance methods
  def destroyable?
    true
  end

  def mark_previous_attempts_as_latest_false
    previous = CourseModuleElementUserLog.where(user_id: self.user_id, course_module_element_id: self.course_module_element_id, latest_attempt: true).where('id < ?', self.id)
    previous.update_attributes(latest_attempt: false)
  end

  def self.asssign_user_to_session_guid(the_user_id, the_session_guid)
    # activate this with the following:  CourseModuleElementUserLog.assign_user_to_session_guid( 123, 'abcde123')
    CourseModuleElementUserLog.for_session_guid(the_session_guid).for_unknown_users.update_attributes(user_id: the_user_id)
  end

  protected

  def set_latest_attempt
    self.latest_attempt = true
    others = CourseModuleElementUserLog.for_user_or_session(self.user_id, self.session_guid).
        for_course_module_element(self.course_module_element_id).latest_only
    others.update_all(latest_attempt: false)
  end

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

end
