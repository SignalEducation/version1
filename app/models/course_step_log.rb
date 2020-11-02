# frozen_string_literal: true

# == Schema Information
#
# Table name: course_step_logs
#
#  id                         :integer          not null, primary key
#  course_step_id             :integer
#  user_id                    :integer
#  session_guid               :string(255)
#  element_completed          :boolean          default("false"), not null
#  time_taken_in_seconds      :integer
#  quiz_score_actual          :integer
#  quiz_score_potential       :integer
#  is_video                   :boolean          default("false"), not null
#  is_quiz                    :boolean          default("false"), not null
#  course_lesson_id           :integer
#  latest_attempt             :boolean          default("true"), not null
#  created_at                 :datetime
#  updated_at                 :datetime
#  seconds_watched            :integer          default("0")
#  count_of_questions_taken   :integer
#  count_of_questions_correct :integer
#  course_id                  :integer
#  course_lesson_log_id       :integer
#  course_log_id              :integer
#  is_constructed_response    :boolean          default("false")
#  preview_mode               :boolean          default("false")
#  course_section_id          :integer
#  course_section_log_id      :integer
#  quiz_result                :integer
#  is_note                    :boolean          default("false")
#  is_practice_question       :boolean          default("false")
#
class CourseStepLog < ApplicationRecord
  include LearnSignalModelExtras

  # enum
  enum quiz_result: { started: 0, failed: 1, passed: 2 }

  # relationships
  belongs_to :user, optional: true
  belongs_to :course, optional: true
  belongs_to :course_log, optional: true
  belongs_to :course_section, optional: true
  belongs_to :course_section_log, optional: true
  belongs_to :course_lesson, optional: true
  belongs_to :course_lesson_log, optional: true
  belongs_to :course_step, optional: true
  has_many   :quiz_attempts, inverse_of: :course_step_log
  has_many   :practice_question_answers, inverse_of: :course_step_log, class_name: 'PracticeQuestion::Answer'
  has_one    :constructed_response_attempt
  accepts_nested_attributes_for :quiz_attempts, :constructed_response_attempt
  accepts_nested_attributes_for :practice_question_answers

  # validation
  validates :user_id, presence: true
  validates :course_id, presence: true
  validates :course_section_id, presence: true
  validates :course_lesson_id, presence: true
  validates :quiz_score_actual, presence: true, if: proc { |log| log.is_quiz == true }, on: :update
  validates :quiz_score_potential, presence: true, if: proc { |log| log.is_quiz == true }, on: :update

  # callbacks
  before_validation :create_course_lesson_log, unless: :course_lesson_log_id
  before_create :set_latest_attempt, :set_booleans
  after_create :update_previous_attempts
  after_save :update_course_lesson_log

  # scopes
  scope :all_in_order, -> { order(:course_step_id) }
  scope :all_completed, -> { where(element_completed: true) }
  scope :all_incomplete, -> { where(element_completed: false) }
  scope :for_user, ->(user_id) { where(user_id: user_id) }
  scope :for_course_lesson, ->(module_id) { where(course_lesson_id: module_id) }
  scope :for_course_step, ->(element_id) { where(course_step_id: element_id) }
  scope :for_course, ->(course_id) { where(course_id: course_id) }
  scope :for_current_user, ->(current_user_id) { where(user_id: current_user_id) }
  scope :latest_only, -> { where(latest_attempt: true) }
  scope :quizzes, -> { where(is_quiz: true) }
  scope :videos, -> { where(is_video: true) }
  scope :notes, -> { where(is_note: true) }
  scope :practice_questions, -> { where(is_practice_question: true) }
  scope :constructed_responses, -> { where(is_constructed_response: true) }
  scope :with_elements_active, -> { includes(:course_step).where('course_steps.active = ?', true).references(:course_steps) }
  scope :this_week, -> { where(created_at: Time.zone.now.beginning_of_week..Time.zone.now.end_of_week) }
  scope :this_month, -> { where(created_at: Time.zone.now.beginning_of_month..Time.zone.now.end_of_month) }

  # class methods

  ## Structures data in CSV format for Excel downloads ##
  def self.to_csv(options = {})
    # attributes are either model attributes or data generate in methods below
    attributes = %w[cm cme completed type latest score seconds created_at]
    CSV.generate(options) do |csv|
      csv << attributes
      find_each do |course|
        csv << attributes.map { |attr| course.send(attr) }
      end
    end
  end

  def cm
    course_lesson.name
  end

  def cme
    course_step.try(:name)
  end

  def completed
    element_completed
  end

  def type
    if is_quiz?
      'Quiz'
    elsif is_video?
      'Video'
    elsif is_note?
      'Notes'
    elsif is_practice_question?
      'Practice Question'
    elsif is_constructed_response?
      'Constructed Response'
    else
      'Unknown'
    end
  end

  def latest
    latest_attempt
  end

  def score
    quiz_score_actual
  end

  def seconds
    seconds_watched
  end

  # instance methods
  def destroyable?
    quiz_attempts.empty?
  end

  def calculate_score
    course_pass_rate = course_lesson.course.quiz_pass_rate || 75
    pass_rate        = course_lesson.free ? 25 : course_pass_rate
    percentage_score = (quiz_attempts.all_correct.count.to_f / quiz_attempts.count.to_f * 100.0).to_i
    passed           = percentage_score >= pass_rate
    quiz_result      = passed ? 'passed' : 'failed'

    update_columns(count_of_questions_taken: quiz_attempts.count,
                   count_of_questions_correct: quiz_attempts.all_correct.count,
                   quiz_score_actual: percentage_score,
                   quiz_score_potential: quiz_attempts.count,
                   quiz_result: quiz_result,
                   element_completed: passed)
  end

  def build_practice_question_answers
    course_step.course_practice_question.questions.each do |question|
      next if practice_question_answers.map(&:practice_question_question_id).include?(question.id)

      practice_question_answers.create(content: question.content,
                                       practice_question_question_id: question.id)
    end
  end

  protected

  # Before Validation
  # This triggers the creation of parent CSUL and its parent SCUL
  def create_course_lesson_log
    set = CourseLessonLog.create!(user_id: user_id, course_lesson_id: course_lesson_id,
                                   course_section_id: course_lesson.course_section_id,
                                   course_id: course_section.course_id,
                                   course_section_log_id: try(:course_section_log_id),
                                   course_log_id: try(:course_log_id))
    self.course_lesson_log_id = set.id
    self.course_section_log_id = set.course_section_log_id
    self.course_log_id = set.course_log_id
  end

  # Before Create
  def set_booleans
    if course_step.is_quiz
      self.is_quiz = true
    elsif course_step.is_video
      self.is_video = true
    elsif course_step.is_note
      self.is_note = true
    elsif course_step.is_practice_question
      self.is_practice_question = true
    elsif course_step.is_constructed_response
      self.is_constructed_response = true
    else
      self.is_video = true
    end

    true
  end

  # Before Create
  def set_latest_attempt
    self.latest_attempt = true unless preview_mode
  end

  # Before Create
  def update_previous_attempts
    UpdatePreviousAttemptsWorker.perform_async(user_id, course_step_id, id)
  end

  # After Update

  # After Save
  def update_course_lesson_log
    lesson_log = course_lesson_log
    lesson_log.latest_course_step_id = course_step_id if element_completed
    lesson_log.recalculate_set_completeness # Includes a save!
  end
end
