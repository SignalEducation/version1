class QuizAnswer < ActiveRecord::Base

  # attr-accessible
  attr_accessible :quiz_question_id, :correct, :degree_of_wrongness, :wrong_answer_explanation_text, :wrong_answer_video_id

  # Constants

  # relationships
  belongs_to :quiz_question
  belongs_to :wrong_answer_video

  # validation
  validates :quiz_question_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :degree_of_wrongness, presence: true
  validates :wrong_answer_explanation_text, presence: true
  validates :wrong_answer_video_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:quiz_question_id) }

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
