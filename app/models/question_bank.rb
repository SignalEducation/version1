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
#  name                        :string
#  active                      :boolean          default(FALSE)
#

class QuestionBank < ActiveRecord::Base

  include LearnSignalModelExtras

  # attr-accessible
  attr_accessible :question_selection_strategy, :subject_course_id, :number_of_questions, :name, :active

  # Constants
  STRATEGIES = %w(random)

  # relationships
  belongs_to :subject_course
  has_many :course_module_element_user_logs

  # validation
  validates :subject_course_id, presence: true
  validates :number_of_questions, presence: true
  validates :question_selection_strategy, inclusion: {in: STRATEGIES}, length: {maximum: 255}
  validates :name, presence: true

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:user_id) }
  scope :all_active, -> { where(active: true) }

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
