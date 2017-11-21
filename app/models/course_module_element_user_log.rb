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
#  subject_course_id          :integer
#  student_exam_track_id      :integer
#  subject_course_user_log_id :integer
#

class CourseModuleElementUserLog < ActiveRecord::Base

  include LearnSignalModelExtras

  # attr-accessible
  attr_accessible :course_module_element_id, :user_id, :session_guid,
                  :element_completed, :time_taken_in_seconds,
                  :quiz_score_actual, :quiz_score_potential,
                  :is_video, :is_quiz, :course_module_id,
                  :quiz_attempts_attributes, :seconds_watched,
                  :count_of_questions_taken, :count_of_questions_correct,
                  :subject_course_id, :student_exam_track_id,
                  :subject_course_user_log_id

  # Constants

  # relationships
  belongs_to :subject_course_user_log
  belongs_to :student_exam_track
  belongs_to :subject_course
  belongs_to :course_module
  belongs_to :course_module_element
  belongs_to :user
  has_many   :quiz_attempts, inverse_of: :course_module_element_user_log

  accepts_nested_attributes_for :quiz_attempts

  # validation
  validates :user_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :session_guid, allow_nil: true, length: {maximum: 255}
  validates :student_exam_track_id, allow_nil: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :subject_course_user_log_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :quiz_score_actual, presence: true, if: 'is_quiz == true', on: :update
  validates :quiz_score_potential, presence: true, if: 'is_quiz == true', on: :update

  # callbacks
  before_create :set_latest_attempt, :set_booleans
  after_create :calculate_score
  after_save :add_to_user_trial_limit, :create_or_update_student_exam_track
  after_create :create_lesson_intercom_event

  # scopes
  scope :all_in_order, -> { order(:course_module_element_id) }
  scope :all_completed, -> { where(element_completed: true) }
  scope :all_incomplete, -> { where(element_completed: false) }
  scope :for_course_module, lambda { |module_id| where(course_module_id: module_id) }
  scope :for_course_module_element, lambda { |element_id| where(course_module_element_id: element_id) }
  scope :for_subject_course, lambda { |course_id| where(subject_course_id: course_id) }
  scope :latest_only, -> { where(latest_attempt: true) }
  scope :quizzes, -> { where(is_quiz: true) }
  scope :videos, -> { where(is_video: true) }
  scope :with_elements_active, -> { includes(:course_module_element).where('course_module_elements.active = ?', true).references(:course_module_elements) }
  scope :this_week, -> { where(created_at: Time.now.beginning_of_week..Time.now.end_of_week) }
  scope :this_month, -> { where(created_at: Time.now.beginning_of_month..Time.now.end_of_month) }
  scope :one_month_ago, -> { where(created_at: 1.month.ago.beginning_of_month..1.month.ago.end_of_month) }
  scope :two_months_ago, -> { where(created_at: 2.month.ago.beginning_of_month..2.month.ago.end_of_month) }
  scope :three_months_ago, -> { where(created_at: 3.month.ago.beginning_of_month..3.month.ago.end_of_month) }

  # class methods



  # instance methods
  def destroyable?
    #self.quiz_attempts.empty?
    true
  end

  def recent_attempts
    CourseModuleElementUserLog.for_user_or_session(self.user_id, self.session_guid).where(course_module_element_id: self.course_module_element_id, latest_attempt: false).order(created_at: :desc).limit(5)
  end

  def old_set
    StudentExamTrack.for_user_or_session(self.user_id, self.session_guid).where(course_module_id: self.course_module_id).first
  end

  protected

  def calculate_score
    if self.is_quiz
      course_pass_rate = self.course_module.subject_course.quiz_pass_rate ? self.course_module.subject_course.quiz_pass_rate : 75
      percentage_score = ((self.quiz_attempts.all_correct.count.to_f)/(self.quiz_attempts.count.to_f) * 100.0).to_i
      passed = percentage_score >= course_pass_rate ? true : false
      self.update_attributes(count_of_questions_taken: self.quiz_attempts.count, count_of_questions_correct: self.quiz_attempts.all_correct.count, quiz_score_actual: percentage_score, quiz_score_potential: self.quiz_attempts.count, element_completed: passed)
    end
  end

  def create_or_update_student_exam_track
    if self.student_exam_track
      #Update SET record
      set = self.student_exam_track
      set.latest_course_module_element_id = self.course_module_element_id if self.element_completed
      set.recalculate_completeness # Includes a save!
    else
      #Create SET and assign it id to this record
      set = StudentExamTrack.new(user_id: self.user_id, session_guid: self.session_guid, course_module_id: self.course_module_id, subject_course_id: self.course_module.subject_course_id, subject_course_user_log_id: self.subject_course_user_log_id)
      set.latest_course_module_element_id = self.course_module_element_id if self.element_completed
      saved_set = set.recalculate_completeness # Includes a save!
      self.update_column(:student_exam_track_id, saved_set.id)
    end
  end

  def add_to_user_trial_limit
    user = self.user
    if user.trial_or_sub_user? && user.valid_free_member?
      new_limit = user.trial_limit_in_seconds + self.try(:time_taken_in_seconds)
      if new_limit > ENV['FREE_TRIAL_LIMIT_IN_SECONDS'].to_i
        user.update_columns(trial_limit_in_seconds: new_limit, free_trial_ended_at: Proc.new{Time.now }.call)
      else
        user.update_column(:trial_limit_in_seconds, new_limit)
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
    IntercomLessonStartedWorker.perform_async(self.try(:user).try(:id), self.try(:course_module).try(:subject_course).try(:name), self.course_module.try(:name), self.is_video ? 'Video' : 'Quiz', self.course_module_element.try(:name), self.course_module_element.try(:course_module_element_video).try(:vimeo_guid), self.try(:count_of_questions_correct)) unless Rails.env.test?
  end

  def check_for_enrollment_email_conditions
    #Needs serious improvements and is failing in sidekiq with undefined method `enrollment' for #<SubjectCourseUserLog>
    new_log_ids = []
    time = Proc.new{Time.now}.call
    if self.subject_course_user_log && self.subject_course_user_log.active_enrollment && !self.subject_course_user_log.active_enrollment.expired
      scul = self.subject_course_user_log
      scul.course_module_element_user_logs.each do |log|
        if log.updated_at > (time - 1.day) && log.id != self.id
          new_log_ids << log.id
        end
      end
      if new_log_ids.any? && scul.last_element && scul.last_element.next_element
        EnrollmentEmailWorker.perform_at(24.hours, self.user.email, scul.id, time.to_i, 'send_study_streak_email') unless Rails.env.test?
      end
    end
  end

end
