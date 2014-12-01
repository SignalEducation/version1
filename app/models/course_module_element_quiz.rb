# == Schema Information
#
# Table name: course_module_element_quizzes
#
#  id                                :integer          not null, primary key
#  course_module_element_id          :integer
#  time_limit_seconds                :integer
#  number_of_questions               :integer
#  question_selection_strategy       :string(255)
#  best_possible_score_first_attempt :integer
#  best_possible_score_retry         :integer
#  course_module_jumbo_quiz_id       :integer
#  created_at                        :datetime
#  updated_at                        :datetime
#

class CourseModuleElementQuiz < ActiveRecord::Base

  # attr-accessible
  attr_accessible :course_module_element_id, :time_limit_seconds,
                  :number_of_questions, :best_possible_score_retry,
                  :quiz_questions_attributes

  # Constants

  # relationships
  belongs_to :course_module_element
  belongs_to :course_module_jumbo_quiz
  has_many :quiz_questions

  accepts_nested_attributes_for :quiz_questions

  # validation
  validates :course_module_element_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}, on: :update
  validates :time_limit_seconds, presence: true
  validates :number_of_questions, presence: true, numericality:
            {greater_than_or_equal_to: 4, less_than_or_equal_to: 30,
             only_integer: true}, on: :update
  validates :best_possible_score_first_attempt, presence: true, on: :update
  validates :best_possible_score_retry, presence: true, on: :update

  # callbacks
  before_save :set_jumbo_quiz_id
  before_validation :set_high_score_fields, on: :update
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:course_module_element_id) }

  # class methods

  # instance methods

  def add_an_empty_question
    self.quiz_questions.build
    self.quiz_questions.last.quiz_contents.build(sorting_order: 1)
    4.times do |number|
      self.quiz_questions.last.quiz_answers.build
      self.quiz_questions.last.quiz_answers.last.quiz_contents.build(sorting_order: number + 1)
    end
  end

  def destroyable?
    self.quiz_questions.empty?
  end

  protected

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

  def set_high_score_fields
    max_score = ApplicationController::DIFFICULTY_LEVELS.last[:score]
    self.best_possible_score_retry = self.number_of_questions.to_i * max_score
    # The best possible score for first attempt assumes the first question is easy the next question is medium and all other questions are hard.
    self.best_possible_score_first_attempt = self.best_possible_score_retry
    ApplicationController::DIFFICULTY_LEVELS.each do |level|
      self.best_possible_score_first_attempt -= (max_score - level[:score])
    end
  end

  def set_jumbo_quiz_id
    self.course_module_jumbo_quiz_id = self.course_module_element.try(:course_module).try(:course_module_jumbo_quiz).try(:id)
  end

end
