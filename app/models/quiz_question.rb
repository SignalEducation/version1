class QuizQuestion < ActiveRecord::Base

  # attr-accessible
  attr_accessible :course_module_element_quiz_id, :course_module_element_id, :difficulty_level, :solution_to_the_question, :hints

  # Constants

  # relationships
  belongs_to :course_module_element_quiz
  belongs_to :course_module_element

  # validation
  validates :course_module_element_quiz_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :course_module_element_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :difficulty_level, presence: true
  validates :solution_to_the_question, presence: true
  validates :hints, presence: true

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:course_module_element_quiz_id) }

  # class methods

  # instance methods
  def destroyable?
    true
  end

  protected

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

end
