# == Schema Information
#
# Table name: scenario_question_attempts
#
#  id                                 :integer          not null, primary key
#  constructed_response_attempt_id    :integer
#  course_module_element_user_log_id  :integer
#  user_id                            :integer
#  constructed_response_id            :integer
#  scenario_question_id               :integer
#  status                             :string
#  flagged_for_review                 :boolean          default(FALSE)
#  original_scenario_question_text    :text
#  user_edited_scenario_question_text :text
#  created_at                         :datetime         not null
#  updated_at                         :datetime         not null
#

class ScenarioQuestionAttempt < ActiveRecord::Base

  # attr-accessible
  attr_accessible :constructed_response_attempt_id, :course_module_element_user_log_id, :user_id,
                  :constructed_response_id, :scenario_question_id, :status, :flagged_for_review,
                  :original_scenario_question_text, :user_edited_scenario_question_text

  # Constants
  STATUS = %w(Unseen Seen)

  # relationships
  belongs_to :constructed_response_attempt
  belongs_to :course_module_element_user_log
  belongs_to :user
  belongs_to :constructed_response
  belongs_to :scenario_question

  # validation
  validates :constructed_response_attempt_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :course_module_element_user_log_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :user_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :constructed_response_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :scenario_question_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :status, presence: true
  validates :original_scenario_question_text, presence: true

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:constructed_response_attempt_id) }

  # class methods

  # instance methods
  def destroyable?
    false
  end

  protected

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

end
