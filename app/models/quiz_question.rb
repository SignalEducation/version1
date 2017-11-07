# == Schema Information
#
# Table name: quiz_questions
#
#  id                            :integer          not null, primary key
#  course_module_element_quiz_id :integer
#  course_module_element_id      :integer
#  difficulty_level              :string
#  created_at                    :datetime
#  updated_at                    :datetime
#  destroyed_at                  :datetime
#  subject_course_id             :integer
#  sorting_order                 :integer
#  custom_styles                 :boolean          default(FALSE)
#

class QuizQuestion < ActiveRecord::Base

  include LearnSignalModelExtras
  include Archivable

  # attr-accessible
  attr_accessible :course_module_element_quiz_id, :difficulty_level,
                  :quiz_answers_attributes, :quiz_contents_attributes,
                  :quiz_solutions_attributes, :subject_course_id, :sorting_order,
                  :custom_styles

  # Constants

  # relationships
  belongs_to :subject_course
  belongs_to :course_module_element
  belongs_to :course_module_element_quiz
  has_many :quiz_attempts
  has_many :quiz_answers, dependent: :destroy
  has_many :quiz_contents, -> { order(:sorting_order) }, dependent: :destroy
  has_many :quiz_solutions, -> { order(:sorting_order) }, dependent: :destroy,
           class_name: 'QuizContent', foreign_key: :quiz_solution_id

  accepts_nested_attributes_for :quiz_answers, allow_destroy: true
  accepts_nested_attributes_for :quiz_contents, allow_destroy: true
  accepts_nested_attributes_for :quiz_solutions, allow_destroy: true

  # validation
  validates :course_module_element_id, presence: true, on: :update
  validate :at_least_one_answer_is_correct, if: '!Rails.env.test?'

  # callbacks
  before_validation :set_course_module_element
  before_save :set_subject_course_id

  # scopes
  scope :all_in_order, -> { order(:sorting_order) }
  scope :in_created_order, -> { order(:id) }

  # class methods

  # instance methods

  ## Archivable methods ##
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
    counter = 0
    quiz_answers.each do |attrs|
      counter += 1 if attrs[:degree_of_wrongness] == 'correct'
    end
    if counter == 0
      errors.add(:base, 'At least one answer must be marked as correct')
    end
  end

  def set_course_module_element
    self.course_module_element_id = self.course_module_element_quiz.try(:course_module_element_id)
    true
  end

  def set_subject_course_id
    self.subject_course_id = self.course_module_element_quiz.course_module_element.parent.subject_course_id
  end

end
