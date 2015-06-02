# == Schema Information
#
# Table name: question_banks
#
#  id                          :integer          not null, primary key
#  user_id                     :integer
#  exam_level_id               :integer
#  easy_questions              :integer
#  medium_questions            :integer
#  hard_questions              :integer
#  question_selection_strategy :string
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#

class QuestionBank < ActiveRecord::Base

  include LearnSignalModelExtras

  # attr-accessible
  attr_accessible :user_id, :exam_level_id, :easy_questions, :medium_questions, :hard_questions, :question_selection_strategy

  # Constants
  STRATEGIES = %w(random progressive)

  # relationships
  belongs_to :user
  belongs_to :exam_level
  has_many :course_module_element_user_logs

  # validation
  validates :user_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :exam_level_id, presence: true,
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

  def number_of_questions
    (self.easy_questions + self.medium_questions + self.hard_questions).to_i
  end

  protected

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

end
