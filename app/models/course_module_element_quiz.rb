# == Schema Information
#
# Table name: course_module_element_quizzes
#
#  id                                :integer          not null, primary key
#  course_module_element_id          :integer
#  number_of_questions               :integer
#  question_selection_strategy       :string
#  best_possible_score_first_attempt :integer
#  best_possible_score_retry         :integer
#  course_module_jumbo_quiz_id       :integer
#  created_at                        :datetime
#  updated_at                        :datetime
#  destroyed_at                      :datetime
#

class CourseModuleElementQuiz < ActiveRecord::Base

  include LearnSignalModelExtras
  include Archivable

  # Constants
  STRATEGIES = %w(random)
  #STRATEGIES = %w(random progressive)

  # attr-accessible
  attr_accessible :course_module_element_id,
                  :number_of_questions, :quiz_questions_attributes,
                  :question_selection_strategy

  # Constants

  # relationships
  belongs_to :course_module_element
  belongs_to :course_module_jumbo_quiz
  has_many :quiz_questions

  accepts_nested_attributes_for :quiz_questions, reject_if: lambda {|attributes| quiz_question_fields_blank?(attributes) }

  # validation
  validates :course_module_element_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}, on: :update
  validates :number_of_questions, presence: true, numericality:
            {greater_than_or_equal_to: 3, less_than_or_equal_to: 80,
             only_integer: true}, on: :update
  validates :question_selection_strategy, inclusion: {in: STRATEGIES}, length: {maximum: 255}

  # callbacks
  before_save :set_jumbo_quiz_id
  before_update :set_high_score_fields
  after_commit :set_ancestors_best_scores

  # scopes
  scope :all_in_order, -> { order(:course_module_element_id).where(destroyed_at: nil) }

  # class methods

  # instance methods
  def add_an_empty_question
    self.quiz_questions.build
    self.quiz_questions.last.course_module_element_quiz_id = self.id
    self.quiz_questions.last.quiz_solutions.build
    self.quiz_questions.last.quiz_contents.build(sorting_order: 1)
    (self.course_module_element.try(:course_module).try(:subject_course).try(:default_number_of_possible_exam_answers) || 4).times do |number|
      self.quiz_questions.last.quiz_answers.build
      self.quiz_questions.last.quiz_answers.last.quiz_contents.build(sorting_order: number + 1)
    end
  end

  def destroyable?
    true
  end

  def destroyable_children
    the_list = []
    the_list += self.quiz_questions.to_a
    the_list
  end

  def enough_questions?
    if self.question_selection_strategy == 'random'
      lowest_number_of_questions = self.quiz_questions.count
    elsif self.question_selection_strategy == 'progressive'
      lowest_number_of_questions = [self.easy_ids.length, self.medium_ids.length, self.difficult_ids.length].min
    else
      lowest_number_of_questions = 0
    end
    lowest_number_of_questions >= self.number_of_questions
  end

  def easy_ids
    self.quiz_questions.all_easy.map(&:id)
  end

  def medium_ids
    self.quiz_questions.all_medium.map(&:id)
  end

  def difficult_ids
    self.quiz_questions.all_difficult.map(&:id)
  end

  protected

  def set_ancestors_best_scores
    changes = self.previous_changes[:best_possible_score_first_attempt] # [prev,new]
    if changes && changes[0] != changes[1]
      self.course_module_element.course_module.exam_section.try(:save)
      self.course_module_element.course_module.subject_course.save
    end
    true
  end

  def set_high_score_fields
    max_score = ApplicationController::DIFFICULTY_LEVELS.last[:score]
    self.best_possible_score_retry = self.number_of_questions.to_i * max_score
    # The best possible score for first attempt assumes the first question is easy,
    # the next question is medium, and all other questions are hard.
    self.best_possible_score_first_attempt = self.best_possible_score_retry
    ApplicationController::DIFFICULTY_LEVELS.each do |level|
      self.best_possible_score_first_attempt -= (max_score - level[:score])
    end
  end

  def set_jumbo_quiz_id
    self.course_module_jumbo_quiz_id ||= self.course_module_element.try(:course_module).try(:course_module_jumbo_quiz).try(:id)
  end

  def self.quiz_question_fields_blank?(the_attributes)
    (the_attributes['id'].to_i > 0 && the_attributes['quiz_contents_attributes'].blank?) ||
      ( the_attributes['course_module_element_quiz_id'].to_i > 0 &&
        # the_attributes['solution_to_the_question'].blank? &&
        the_attributes['difficulty_level'].blank? &&
        the_attributes['quiz_contents_attributes']['0']['text_content'].blank? &&
        # Answer A
        the_attributes['quiz_answers_attributes']['0']['quiz_contents_attributes']['0']['text_content'].blank? &&
        the_attributes['quiz_answers_attributes']['0']['degree_of_wrongness'].blank? &&
        the_attributes['quiz_answers_attributes']['0']['wrong_answer_explanation_text'].blank? &&
        the_attributes['quiz_answers_attributes']['0']['wrong_answer_explanation_text'].blank? &&
        # Answer B
        the_attributes['quiz_answers_attributes']['1'].try(:[],'quiz_contents_attributes').try(:[],'0').try(:[],'text_content').blank? &&
        the_attributes['quiz_answers_attributes']['1'].try(:[],'degree_of_wrongness').blank? &&
        the_attributes['quiz_answers_attributes']['1'].try(:[],'wrong_answer_explanation_text').blank? &&
        the_attributes['quiz_answers_attributes']['1'].try(:[],'wrong_answer_explanation_text').blank? &&
        # Answer C
        the_attributes['quiz_answers_attributes']['2'].try(:[],'quiz_contents_attributes').try(:[],'0').try(:[],'text_content').blank? &&
        the_attributes['quiz_answers_attributes']['2'].try(:[],'degree_of_wrongness').blank? &&
        the_attributes['quiz_answers_attributes']['2'].try(:[],'wrong_answer_explanation_text').blank? &&
        the_attributes['quiz_answers_attributes']['2'].try(:[],'wrong_answer_explanation_text').blank? &&
        # Answer D
        the_attributes['quiz_answers_attributes']['3'].try(:[],'quiz_contents_attributes').try(:[],'0').try(:[],'text_content').blank? &&
        the_attributes['quiz_answers_attributes']['3'].try(:[],'degree_of_wrongness').blank? &&
        the_attributes['quiz_answers_attributes']['3'].try(:[],'wrong_answer_explanation_text').blank? &&
        the_attributes['quiz_answers_attributes']['3'].try(:[],'wrong_answer_explanation_text').blank? &&
        # Answer E
        the_attributes['quiz_answers_attributes']['4'].try(:[],'quiz_contents_attributes').try(:[],'0').try(:[],'text_content').blank? &&
        the_attributes['quiz_answers_attributes']['4'].try(:[],'degree_of_wrongness').blank? &&
        the_attributes['quiz_answers_attributes']['4'].try(:[],'wrong_answer_explanation_text').blank? &&
        the_attributes['quiz_answers_attributes']['4'].try(:[],'wrong_answer_explanation_text').blank?
      )
  end

end
