# == Schema Information
#
# Table name: flash_quizzes
#
#  id                  :integer          not null, primary key
#  flash_card_stack_id :integer
#  background_color    :string(255)
#  foreground_color    :string(255)
#  created_at          :datetime
#  updated_at          :datetime
#

class FlashQuiz < ActiveRecord::Base

  # attr-accessible
  attr_accessible :flash_card_stack_id, :background_color, :foreground_color,
                  :quiz_questions_attributes

  # Constants

  # relationships
  belongs_to :flash_card_stack, inverse_of: :flash_quiz
  has_many :quiz_questions, inverse_of: :flash_quiz
  accepts_nested_attributes_for :quiz_questions, allow_destroy: true

  # validation
  validates :flash_card_stack_id, presence: true, on: :update
  validates :flash_card_stack_id, allow_nil: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :background_color, presence: true
  validates :foreground_color, presence: true

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:flash_card_stack_id) }

  # class methods

  # instance methods
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

end
