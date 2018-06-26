# == Schema Information
#
# Table name: scenario_answer_attempts
#
#  id                                :integer          not null, primary key
#  scenario_question_attempt_id      :integer
#  constructed_response_attempt_id   :integer
#  course_module_element_user_log_id :integer
#  user_id                           :integer
#  scenario_question_id              :integer
#  constructed_response_id           :integer
#  scenario_answer_template_id       :integer
#  original_answer_template_text     :text
#  user_edited_answer_template_text  :text
#  editor_type                       :string
#  created_at                        :datetime         not null
#  updated_at                        :datetime         not null
#

class ScenarioAnswerAttempt < ActiveRecord::Base

  # attr-accessible
  attr_accessible :scenario_question_attempt_id, :constructed_response_attempt_id,
                  :course_module_element_user_log_id, :user_id, :scenario_question_id,
                  :constructed_response_id, :scenario_answer_template_id,
                  :original_answer_template_text, :user_edited_answer_template_text,
                  :editor_type

  # Constants

  # relationships
  belongs_to :scenario_question_attempt
  belongs_to :constructed_response_attempt
  belongs_to :course_module_element_user_log
  belongs_to :user
  belongs_to :scenario_question
  belongs_to :constructed_response
  belongs_to :scenario_answer_template

  # validation
  validates :scenario_question_attempt_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :constructed_response_attempt_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :course_module_element_user_log_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :user_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :scenario_question_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :constructed_response_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :scenario_answer_template_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :original_answer_template_text, presence: true
  validates :user_edited_answer_template_text, presence: true
  validates :editor_type, presence: true, inclusion: {in: ScenarioAnswerTemplate::FORMAT_TYPES}

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:scenario_question_attempt_id) }

  # class methods

  # instance methods
  def destroyable?
    false
  end

  def spreadsheet_editor?
    editor_type == 'spreadsheet_editor'
  end

  def text_editor?
    editor_type == 'text_editor'
  end


  protected

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

end
