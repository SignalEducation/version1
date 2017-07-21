# == Schema Information
#
# Table name: course_module_element_user_logs
#
#  id                         :integer          not null, primary key
#  course_module_element_id   :integer
#  user_id                    :integer
#  session_guid               :string
#  element_completed          :boolean          default(FALSE), not null
#  time_taken_in_seconds      :integer
#  quiz_score_actual          :integer
#  quiz_score_potential       :integer
#  is_video                   :boolean          default(FALSE), not null
#  is_quiz                    :boolean          default(FALSE), not null
#  course_module_id           :integer
#  latest_attempt             :boolean          default(TRUE), not null
#  created_at                 :datetime
#  updated_at                 :datetime
#  seconds_watched            :integer          default(0)
#  count_of_questions_taken   :integer
#  count_of_questions_correct :integer
#

class CourseModuleElementUserLog < ActiveRecord::Base

  include LearnSignalModelExtras

  # attr-accessible
  attr_accessible :course_module_element_id, :user_id, :session_guid,
                  :element_completed, :time_taken_in_seconds,
                  :quiz_score_actual, :quiz_score_potential,
                  :is_video, :is_quiz, :course_module_id,
                  :quiz_attempts_attributes, :seconds_watched

  # Constants

  # relationships
  belongs_to :course_module
  belongs_to :course_module_element
  has_many   :quiz_attempts, inverse_of: :course_module_element_user_log
  belongs_to :user
  accepts_nested_attributes_for :quiz_attempts

  # validation
  validates :session_guid, presence: true, length: {maximum: 255}
  validates :quiz_score_actual, presence: true, if: 'is_quiz == true', on: :update
  validates :quiz_score_potential, presence: true, if: 'is_quiz == true', on: :update

  # callbacks
  before_create :set_latest_attempt, :set_booleans
  after_save :calculate_score
  after_create :check_for_enrollment_email_conditions
  after_create :create_lesson_intercom_event if Rails.env.production? || Rails.env.staging?
  after_save :add_to_user_trial_limit, :create_or_update_student_exam_track

  # scopes
  scope :all_in_order, -> { order(:course_module_element_id) }
  scope :all_completed, -> { where(element_completed: true) }
  scope :for_session_guid, lambda { |the_guid| where(session_guid: the_guid) }
  scope :for_unknown_users, -> { where(user_id: nil) }
  scope :for_course_module, lambda { |module_id| where(course_module_id: module_id) }
  scope :for_course_module_element, lambda { |element_id| where(course_module_element_id: element_id) }
  scope :latest_only, -> { where(latest_attempt: true) }
  scope :quizzes, -> { where(is_quiz: true) }
  scope :videos, -> { where(is_video: true) }
  scope :with_elements_active, -> { includes(:course_module_element).where('course_module_elements.active = ?', true).references(:course_module_elements) }
  scope :this_week, -> { where(created_at: Time.now.beginning_of_week..Time.now.end_of_week) }
  scope :this_month, -> { where(created_at: Time.now.beginning_of_month..Time.now.end_of_month) }
  scope :one_month_ago, -> { where(created_at: 1.month.ago.beginning_of_month..1.month.ago.end_of_month) }
  scope :two_months_ago, -> { where(created_at: 2.month.ago.beginning_of_month..2.month.ago.end_of_month) }
  scope :three_months_ago, -> { where(created_at: 3.month.ago.beginning_of_month..3.month.ago.end_of_month) }
  scope :four_months_ago, -> { where(created_at: 4.month.ago.beginning_of_month..4.month.ago.end_of_month) }
  scope :five_months_ago, -> { where(created_at: 5.month.ago.beginning_of_month..5.month.ago.end_of_month) }

  # class methods
  def self.assign_user_to_session_guid(the_user_id, the_session_guid)
    # activate this with the following:
    # CourseModuleElementUserLog.assign_user_to_session_guid(123, 'abcde123')
    cmeuls = CourseModuleElementUserLog.for_session_guid(the_session_guid).for_unknown_users
    cmeuls.each do |cmeul|
     cmeul.update_column(:user_id, the_user_id)
     cmeul.quiz_attempts.where(course_module_element_user_log_id: cmeul.id, user_id: nil).update_all(user_id: the_user_id)
    end
    user_cmeuls = CourseModuleElementUserLog.where(user_id: the_user_id).order(course_module_element_id: :asc, updated_at: :desc)
    user_cmeuls.update_all(latest_attempt: false)
    cme_tracker = nil
    user_cmeuls.each do |cmeul|
      unless cmeul.course_module_element_id == cme_tracker
        cmeul.update_column(:latest_attempt, true)
        cme_tracker = cmeul.course_module_element_id
      end
    end
    true
  end

  def self.for_user_or_session(the_user_id, the_session_guid)
    the_user_id ? where(user_id: the_user_id) : where(session_guid: the_session_guid, user_id: nil)
  end

  # instance methods
  def destroyable?
    self.quiz_attempts.empty?
  end

  def recent_attempts
    CourseModuleElementUserLog.for_user_or_session(self.user_id, self.session_guid).where(course_module_element_id: self.course_module_element_id, latest_attempt: false).order(created_at: :desc).limit(5)
  end

  def student_exam_track
    StudentExamTrack.for_user_or_session(self.user_id, self.session_guid).where(course_module_id: self.course_module_id).first
  end

  protected

  def calculate_score
    if self.is_quiz
      course_pass_rate = self.course_module.subject_course.quiz_pass_rate ? self.course_module.subject_course.quiz_pass_rate : 75
      percentage_score = ((self.quiz_attempts.all_correct.count.to_f)/(self.quiz_attempts.count.to_f) * 100.0).to_i

      self.count_of_questions_taken = self.quiz_attempts.count
      self.count_of_questions_correct = self.quiz_attempts.all_correct.count
      self.quiz_score_actual = percentage_score
      self.quiz_score_potential = self.count_of_questions_taken
      self.element_completed = true if percentage_score >= course_pass_rate
    end
  end

  def create_or_update_student_exam_track
    set = self.student_exam_track || StudentExamTrack.new(user_id: self.user_id, session_guid: self.session_guid, course_module_id: self.course_module_id)
    set.subject_course_id ||= self.course_module.subject_course.id
    set.latest_course_module_element_id = self.course_module_element_id if self.element_completed
    set.recalculate_completeness # Includes a save!
  end

  def add_to_user_trial_limit
    user = self.user
    if user.individual_student? && user.valid_free_member?
      new_limit = user.trial_limit_in_seconds + self.try(:time_taken_in_seconds)
      if new_limit > ENV['free_trial_limit_in_seconds'].to_i
        user.update_attributes(trial_limit_in_seconds: new_limit, free_trial_ended_at: Proc.new{Time.now }.call)
      else
        user.update_attribute(:trial_limit_in_seconds, new_limit)
      end
    end
  end

  def set_booleans
    if self.course_module_element.course_module_element_quiz
      self.is_quiz = true
    else
      self.is_video = true
    end
    true
  end

  def set_latest_attempt
    self.latest_attempt = true
    others = CourseModuleElementUserLog.for_user_or_session(self.user_id, self.session_guid).where(course_module_element_id: self.course_module_element_id).latest_only
    others.update_all(latest_attempt: false)
    true
  end

  def create_lesson_intercom_event
    IntercomLessonStartedWorker.perform_async(self.try(:user).try(:id), self.try(:course_module).try(:subject_course).try(:name), self.course_module.try(:name), self.is_video ? 'Video' : 'Quiz', self.course_module_element.try(:name), self.course_module_element.try(:course_module_element_video).try(:video_id), self.try(:count_of_questions_correct))
  end

  def check_for_enrollment_email_conditions
    new_log_ids = []
    time = Proc.new{Time.now}.call
    if self.student_exam_track && self.student_exam_track.subject_course_user_log && self.student_exam_track.subject_course_user_log.enrollment
      scul = self.student_exam_track.subject_course_user_log
      scul.student_exam_tracks.each do |set|
        set.cme_user_logs.each do |log|
          new_log_ids << log.id if log.updated_at > (time - 1.day) && log != self
        end
      end
      if new_log_ids.empty? && scul.last_element.next_element
        EnrollmentEmailWorker.perform_at(24.hours, self.user.email, scul.id, time.to_i, 'send_study_streak_email')
      end
    end
  end

end
