# == Schema Information
#
# Table name: scenario_answer_attempts
#
#  id                               :integer          not null, primary key
#  scenario_question_attempt_id     :integer
#  user_id                          :integer
#  scenario_answer_template_id      :integer
#  original_answer_template_text    :text
#  user_edited_answer_template_text :text
#  editor_type                      :string
#  created_at                       :datetime         not null
#  updated_at                       :datetime         not null
#  sorting_order                    :integer
#

class ScenarioAnswerAttempt < ApplicationRecord

  # Constants

  # relationships
  belongs_to :scenario_question_attempt
  belongs_to :user
  belongs_to :scenario_answer_template

  # validation
  validates :scenario_question_attempt_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :user_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :scenario_answer_template_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :editor_type, presence: true, inclusion: {in: ScenarioAnswerTemplate::FORMAT_TYPES}

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:sorting_order, :scenario_question_attempt_id) }

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
