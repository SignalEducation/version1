# == Schema Information
#
# Table name: quiz_questions
#
#  id                            :integer          not null, primary key
#  course_module_element_quiz_id :integer
#  course_module_element_id      :integer
#  difficulty_level              :string(255)
#  solution_to_the_question      :text
#  hints                         :text
#  created_at                    :datetime
#  updated_at                    :datetime
#

class QuizQuestion < ActiveRecord::Base

  # attr-accessible
  attr_accessible :course_module_element_quiz_id,
                  :difficulty_level, :solution_to_the_question, :hints

  # Constants

  # relationships
  belongs_to :course_module_element
  belongs_to :course_module_element_quiz
  has_many :quiz_attempts
  has_many :quiz_answers
  has_many :quiz_contents, -> { order(:sorting_order) }

  # validation
  validates :course_module_element_quiz_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :course_module_element_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :difficulty_level, inclusion: {in: ApplicationController::DIFFICULTY_LEVELS}
  validates :solution_to_the_question, presence: true
  validates :hints, allow_nil: true, length: {maximum: 65535}

  # callbacks
  before_save :set_course_module_element
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:course_module_element_quiz_id) }

  # class methods

  # instance methods
  def destroyable?
    self.quiz_answers.empty? && self.quiz_attempts.empty? && self.quiz_contents.empty?
  end

  protected

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

  def set_course_module_element
    self.course_module_element_id = self.course_module_element_quiz.course_module_element_id
  end

end
