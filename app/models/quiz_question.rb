# == Schema Information
#
# Table name: quiz_questions
#
#  id                            :integer          not null, primary key
#  course_module_element_quiz_id :integer
#  course_module_element_id      :integer
#  difficulty_level              :string
#  hints                         :text
#  created_at                    :datetime
#  updated_at                    :datetime
#  flash_quiz_id                 :integer
#  destroyed_at                  :datetime
#  exam_level_id                 :integer
#  exam_section_id               :integer
#

class QuizQuestion < ActiveRecord::Base

  include LearnSignalModelExtras
  include Archivable

  # attr-accessible
  attr_accessible :course_module_element_quiz_id,
                  :difficulty_level, :hints,
                  :quiz_answers_attributes, :quiz_contents_attributes,
                  :quiz_solutions_attributes, :flash_quiz_id, :exam_level_id

  # Constants

  # relationships
  belongs_to :course_module_element
  belongs_to :course_module_element_quiz
  belongs_to :flash_quiz, inverse_of: :quiz_questions
  has_many :quiz_attempts
  has_many :quiz_answers, dependent: :destroy
  has_many :quiz_contents, -> { order(:sorting_order) }, dependent: :destroy
  has_many :quiz_solutions, -> { order(:sorting_order) }, dependent: :destroy,
           class_name: 'QuizContent', foreign_key: :quiz_solution_id

  accepts_nested_attributes_for :quiz_answers, allow_destroy: true
  accepts_nested_attributes_for :quiz_contents, allow_destroy: true
  accepts_nested_attributes_for :quiz_solutions, allow_destroy: true

  # validation
  validates :course_module_element_quiz_id, allow_nil: true,
            numericality: {only_integer: true, greater_than: 0}, on: :update
  validates :course_module_element_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}, on: :update
  validates :difficulty_level, inclusion: {in: ApplicationController::DIFFICULTY_LEVEL_NAMES}, length: { maximum: 255}
  validates :hints, allow_nil: true, length: {maximum: 65535}
  # todo validate :at_least_one_answer_is_correct

  # callbacks
  before_validation :set_course_module_element
  before_save :set_exam_level_id
  before_save :set_exam_section_id
  before_update :set_exam_level_id
  before_update :set_exam_section_id

  # scopes
  scope :all_in_order, -> { order(:course_module_element_quiz_id) }
  scope :all_easy, -> { where(difficulty_level: 'easy') }
  scope :all_medium, -> { where(difficulty_level: 'medium') }
  scope :all_difficult, -> { where(difficulty_level: 'difficult') }

  # class methods

  # instance methods

  def complex_question?
    answer_ids = self.quiz_answer_ids
    self.quiz_contents.count > 1 || self.quiz_solutions.count > 1 || self.quiz_contents.all_images.count > 0 || self.quiz_contents.all_mathjaxes.count > 0 || QuizContent.where(quiz_answer_id: answer_ids, quiz_question_id: nil, quiz_solution_id: nil, flash_card_id: nil).count > 4
  end

  def destroyable?
    true
  end

  def destroyable_children
    the_list = []
    the_list += self.quiz_answers.to_a
    the_list += self.quiz_contents.to_a
    the_list += self.quiz_solutions.to_a
    the_list
  end

  protected

  def at_least_one_answer_is_correct
    # todo - this doesn't work
    counter = 0
    quiz_answers_attributes.each do |attrs|
      counter += 1 if attrs[:degree_of_wrongness] == 'correct'
    end
    if counter == 0
      errors.add(:base, 'At least one answer must be marked as correct')
    end
  end

  def set_course_module_element
    self.course_module_element_id = self.course_module_element_quiz.try(:course_module_element_id) || self.flash_quiz.try(:flash_card_stack).try(:course_module_element_flash_card_pack).try(:course_module_element_id)
    true
  end

  def set_exam_level_id
    unless self.flash_quiz_id
      self.exam_level_id = self.course_module_element_quiz.course_module_element.parent.exam_level_id
    end
  end

  def set_exam_section_id
    unless self.flash_quiz_id
      if self.course_module_element_quiz.course_module_element.course_module.exam_section_id
        self.exam_section_id = self.course_module_element_quiz.course_module_element.parent.exam_section_id
      end
    end
  end

end
