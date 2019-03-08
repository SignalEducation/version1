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
#  is_constructed_response    :boolean          default(FALSE)
#  preview_mode               :boolean          default(FALSE)
#

class CourseModuleElementUserLog < ActiveRecord::Base

  include LearnSignalModelExtras

  # Constants

  # relationships
  belongs_to :subject_course_user_log, optional: true
  belongs_to :student_exam_track, optional: true
  belongs_to :subject_course, optional: true
  belongs_to :course_module, optional: true
  belongs_to :course_module_element
  belongs_to :user
  has_many   :quiz_attempts, inverse_of: :course_module_element_user_log
  has_one   :constructed_response_attempt

  accepts_nested_attributes_for :quiz_attempts, :constructed_response_attempt


  # validation
  validates :user_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :session_guid, allow_nil: true, length: {maximum: 255}
  validates :student_exam_track_id, allow_nil: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :subject_course_user_log_id, allow_nil: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :quiz_score_actual, presence: true, if: Proc.new { |log| log.is_quiz == true }, on: :update
  validates :quiz_score_potential, presence: true, if: Proc.new { |log| log.is_quiz == true }, on: :update

  # callbacks
  before_create :set_latest_attempt, :set_booleans
  after_create :calculate_score, :update_user_seconds_consumed, :create_lesson_intercom_event
  after_save :update_user_seconds_consumed_for_videos, :create_or_update_student_exam_track

  # scopes
  scope :all_in_order, -> { order(:course_module_element_id) }
  scope :all_completed, -> { where(element_completed: true) }
  scope :all_incomplete, -> { where(element_completed: false) }
  scope :for_user, lambda { |user_id| where(user_id: user_id) }
  scope :for_course_module, lambda { |module_id| where(course_module_id: module_id) }
  scope :for_course_module_element, lambda { |element_id| where(course_module_element_id: element_id) }
  scope :for_subject_course, lambda { |course_id| where(subject_course_id: course_id) }
  scope :for_current_user, lambda { |current_user_id| where(user_id: current_user_id) }
  scope :latest_only, -> { where(latest_attempt: true) }
  scope :quizzes, -> { where(is_quiz: true) }
  scope :videos, -> { where(is_video: true) }
  scope :constructed_responses, -> { where(is_constructed_response: true) }
  scope :with_elements_active, -> { includes(:course_module_element).where('course_module_elements.active = ?', true).references(:course_module_elements) }
  scope :this_week, -> { where(created_at: Time.now.beginning_of_week..Time.now.end_of_week) }
  scope :this_month, -> { where(created_at: Time.now.beginning_of_month..Time.now.end_of_month) }
  scope :one_month_ago, -> { where(created_at: 1.month.ago.beginning_of_month..1.month.ago.end_of_month) }
  scope :two_months_ago, -> { where(created_at: 2.month.ago.beginning_of_month..2.month.ago.end_of_month) }
  scope :three_months_ago, -> { where(created_at: 3.month.ago.beginning_of_month..3.month.ago.end_of_month) }

  # class methods

  ## Structures data in CSV format for Excel downloads ##
  def self.to_csv(options = {})
    #attributes are either model attributes or data generate in methods below
    attributes = %w{cm cme completed type latest score seconds created_at}
    CSV.generate(options) do |csv|
      csv << attributes
      all.each do |course|
        csv << attributes.map{ |attr| course.send(attr) }
      end
    end
  end


  def cm
    self.course_module.name
  end

  def cme
    self.course_module_element.try(:name)
  end

  def completed
    self.element_completed
  end

  def type
    if self.is_quiz?
      'Quiz'
    elsif self.is_video?
      'Video'
    elsif self.is_constructed_response?
      'Constructed Response'
    else
      'Unknown'
    end
  end

  def latest
    self.latest_attempt
  end

  def score
    self.quiz_score_actual
  end

  def seconds
    self.seconds_watched
  end

  # instance methods
  def destroyable?
    #self.quiz_attempts.empty?
    true
  end

  def recent_attempts
    CourseModuleElementUserLog.for_user(self.user_id).where(course_module_element_id: self.course_module_element_id, latest_attempt: false).order(created_at: :desc).limit(5)
  end


  protected

  # After Create
  def calculate_score
    if self.is_quiz
      course_pass_rate = self.course_module.subject_course.quiz_pass_rate ? self.course_module.subject_course.quiz_pass_rate : 75
      percentage_score = ((self.quiz_attempts.all_correct.count.to_f)/(self.quiz_attempts.count.to_f) * 100.0).to_i
      passed = percentage_score >= course_pass_rate ? true : false
      self.update_columns(count_of_questions_taken: self.quiz_attempts.count, count_of_questions_correct: self.quiz_attempts.all_correct.count, quiz_score_actual: percentage_score, quiz_score_potential: self.quiz_attempts.count, element_completed: passed)
    end
  end

  # After Save
  def create_or_update_student_exam_track
    unless self.preview_mode
      if self.student_exam_track
        #Update SET record
        set = self.student_exam_track
        set.latest_course_module_element_id = self.course_module_element_id if self.element_completed
        set.recalculate_completeness # Includes a save!
      else
        #Create SET and assign it id to this record
        set = StudentExamTrack.new(user_id: self.user_id, course_module_id: self.course_module_id, subject_course_id: self.course_module.subject_course_id, subject_course_user_log_id: self.subject_course_user_log_id)
        set.latest_course_module_element_id = self.course_module_element_id if self.element_completed
        saved_set = set.recalculate_completeness # Includes a save!
        self.update_column(:student_exam_track_id, saved_set.id)
      end
    end
  end

  # After Create
  # Need to always update the student_access limit to the new limit
  # Trigger the check trial access still valid if a trial user
  def update_user_seconds_consumed
    unless self.preview_mode
      user = self.user
      current_seconds_consumed = user.student_access.content_seconds_consumed
      updated_seconds_consumed = current_seconds_consumed + self.try(:time_taken_in_seconds)
      user.student_access.update_attribute(:content_seconds_consumed, updated_seconds_consumed)
    end
  end

  # After Save
  # Only update the student_access if it is a video log
  # TODO - Issue here with video seconds watched. Update there when Vimeo tracking is accurate
  def update_user_seconds_consumed_for_videos
    if self.is_video && !self.preview_mode
      user = self.user
      current_seconds_consumed = user.student_access.content_seconds_consumed
      updated_seconds_consumed = current_seconds_consumed + self.try(:time_taken_in_seconds)
      user.student_access.update_attribute(:content_seconds_consumed, updated_seconds_consumed)
    end
  end

  # Before Create
  def set_booleans
    if self.course_module_element.is_quiz
      self.is_quiz = true
    elsif self.course_module_element.is_video
      self.is_video = true
    elsif self.course_module_element.is_constructed_response
      self.is_constructed_response = true
    else
      self.is_video = true
    end
    true
  end

  # Before Create
  def set_latest_attempt
    unless self.preview_mode
      CourseModuleElementUserLog.for_user(self.user_id).where(course_module_element_id: self.course_module_element_id).latest_only.update_all(latest_attempt: false)
      self.latest_attempt = true
      true
    end
  end

  # After Save
  def create_lesson_intercom_event
    unless self.preview_mode || Rails.env.test?
      IntercomLessonStartedWorker.perform_async(self.try(:user).try(:id), self.try(:course_module).try(:subject_course).try(:name), self.course_module.try(:name), self.type, self.course_module_element.try(:name), self.course_module_element.try(:course_module_element_video).try(:vimeo_guid), self.try(:count_of_questions_correct))
    end
  end


end
