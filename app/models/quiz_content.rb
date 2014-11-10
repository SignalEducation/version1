class QuizContent < ActiveRecord::Base

  # attr-accessible
  attr_accessible :quiz_question_id, :quiz_answer_id, :text_content, :contains_mathjax, :contains_image, :sorting_order

  # Constants

  # relationships
  belongs_to :quiz_question
  belongs_to :quiz_answer

  # validation
  validates :quiz_question_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :quiz_answer_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :text_content, presence: true
  validates :sorting_order, presence: true

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:sorting_order, :quiz_question_id) }

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
