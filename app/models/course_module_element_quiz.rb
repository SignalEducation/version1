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
                  :number_of_questions,
                  :quiz_questions_attributes

  # Constants

  # relationships
  belongs_to :course_module_element
  belongs_to :course_module_jumbo_quiz
  has_many :quiz_questions

  accepts_nested_attributes_for :quiz_questions, reject_if: lambda {|attributes| quiz_question_fields_blank?(attributes) }

  # validation
  validates :course_module_element_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}, on: :update
  validates :time_limit_seconds, presence: true
  validates :number_of_questions, presence: true, numericality:
            {greater_than_or_equal_to: 4, less_than_or_equal_to: 30,
             only_integer: true}, on: :update

  # callbacks
  before_save :set_jumbo_quiz_id
  before_update :set_high_score_fields
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:course_module_element_id) }

  # class methods

  # instance methods

  def add_an_empty_question
    self.quiz_questions.build
    self.quiz_questions.last.course_module_element_quiz_id = self.id
    self.quiz_questions.last.quiz_contents.build(sorting_order: 1)
    (self.course_module_element.try(:course_module).try(:exam_level).try(:default_number_of_possible_exam_answers) || 4) .times do |number|
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

  def self.quiz_question_fields_blank?(the_attributes)
    puts '*' * 100
    puts the_attributes.inspect
    puts '*' * 100
    (the_attributes['id'].to_i > 0 && the_attributes['quiz_contents_attributes'].blank?) ||
      ( the_attributes['course_module_element_quiz_id'].to_i > 0 &&
        the_attributes['solution_to_the_question'].blank? &&
        the_attributes['difficulty_level'].blank? &&
        the_attributes['quiz_contents_attributes']['0']['text_content'].blank? &&
        # Answer A
        the_attributes['quiz_answers_attributes']['0']['quiz_contents_attributes']['0']['text_content'].blank? &&
        the_attributes['quiz_answers_attributes']['0']['degree_of_wrongness'].blank? &&
        the_attributes['quiz_answers_attributes']['0']['wrong_answer_explanation_text'].blank? &&
        the_attributes['quiz_answers_attributes']['0']['wrong_answer_explanation_text'].blank? &&
        # Answer B
        the_attributes['quiz_answers_attributes']['1']['quiz_contents_attributes']['0']['text_content'].blank? &&
        the_attributes['quiz_answers_attributes']['1']['degree_of_wrongness'].blank? &&
        the_attributes['quiz_answers_attributes']['1']['wrong_answer_explanation_text'].blank? &&
        the_attributes['quiz_answers_attributes']['1']['wrong_answer_explanation_text'].blank? &&
        # Answer C
        the_attributes['quiz_answers_attributes']['2']['quiz_contents_attributes']['0']['text_content'].blank? &&
        the_attributes['quiz_answers_attributes']['2']['degree_of_wrongness'].blank? &&
        the_attributes['quiz_answers_attributes']['2']['wrong_answer_explanation_text'].blank? &&
        the_attributes['quiz_answers_attributes']['2']['wrong_answer_explanation_text'].blank? &&
        # Answer D
        the_attributes['quiz_answers_attributes']['3']['quiz_contents_attributes']['0']['text_content'].blank? &&
        the_attributes['quiz_answers_attributes']['3']['degree_of_wrongness'].blank? &&
        the_attributes['quiz_answers_attributes']['3']['wrong_answer_explanation_text'].blank? &&
        the_attributes['quiz_answers_attributes']['3']['wrong_answer_explanation_text'].blank?
      )
  end

end
