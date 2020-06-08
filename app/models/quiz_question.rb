# == Schema Information
#
# Table name: quiz_questions
#
#  id               :integer          not null, primary key
#  course_quiz_id   :integer
#  course_step_id   :integer
#  difficulty_level :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#  destroyed_at     :datetime
#  course_id        :integer
#  sorting_order    :integer
#  custom_styles    :boolean          default("false")
#

class QuizQuestion < ApplicationRecord

  include LearnSignalModelExtras
  include Archivable

  # Constants

  # relationships
  belongs_to :course, optional: true
  belongs_to :course_step, optional: true
  belongs_to :course_quiz
  has_many :quiz_attempts
  has_many :quiz_answers, dependent: :destroy
  has_many :quiz_contents, -> { order(:sorting_order) }, dependent: :destroy
  has_many :quiz_solutions, -> { order(:sorting_order) }, dependent: :destroy,
           class_name: 'QuizContent', foreign_key: :quiz_solution_id

  accepts_nested_attributes_for :quiz_answers, allow_destroy: true
  accepts_nested_attributes_for :quiz_contents, allow_destroy: true
  accepts_nested_attributes_for :quiz_solutions, allow_destroy: true

  # validation
  validates :course_step_id, presence: true, on: :update
  validate :at_least_one_answer_is_correct

  # callbacks
  before_validation :set_course_step
  before_create :set_sorting_order

  # scopes
  scope :all_in_order, -> { order(:sorting_order) }
  scope :in_created_order, -> { order(:id) }

  # class methods

  # instance methods

  ## Parent & Child associations ##

  def parent
    course_quiz
  end

  def children
    quiz_answers
  end

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
    if quiz_answers.any? && !quiz_answers.map(&:degree_of_wrongness).include?('correct')
      errors.add(:base, 'At least one answer must be marked as correct')
    end
  end

  def set_course_step
    self.course_step_id = self.course_quiz.try(:course_step_id)
    true
  end

end
