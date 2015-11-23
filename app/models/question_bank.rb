# == Schema Information
#
# Table name: question_banks
#
#  id                          :integer          not null, primary key
#  question_selection_strategy :string
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#  subject_course_id           :integer
#  number_of_questions         :integer
#

class QuestionBank < ActiveRecord::Base

  include LearnSignalModelExtras

  # attr-accessible
  attr_accessible :question_selection_strategy, :subject_course_id, :number_of_questions

  # Constants
  STRATEGIES = %w(random)

  # relationships
  #belongs_to :user
  belongs_to :subject_course
  has_many :course_module_element_user_logs

  # validation
  validates :subject_course_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :number_of_questions, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :question_selection_strategy, inclusion: {in: STRATEGIES}, length: {maximum: 255}

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:user_id) }

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

  def at_least_one_question_set
    if number_of_questions < 1
      errors.add(:base, I18n.t('controllers.question_banks.at_least_one_question_set'))
    end
  end

end
