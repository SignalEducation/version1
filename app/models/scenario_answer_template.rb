# == Schema Information
#
# Table name: scenario_answer_templates
#
#  id                       :integer          not null, primary key
#  course_module_element_id :integer
#  constructed_response_id  :integer
#  scenario_id              :integer
#  scenario_question_id     :integer
#  sorting_order            :integer
#  editor_type              :string
#  text_content             :text
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#

class ScenarioAnswerTemplate < ActiveRecord::Base

  serialize :text_content, JSON

  # attr-accessible
  attr_accessible :course_module_element_id, :constructed_response_id,
                  :scenario_id, :scenario_question_id,
                  :sorting_order, :editor_type, :text_content

  # Constants
  FORMAT_TYPES = %w(text_editor spreadsheet_editor)


  # relationships
  belongs_to :course_module_element
  belongs_to :constructed_response
  belongs_to :scenario
  belongs_to :scenario_question

  # validation
  validates :scenario_question_id, presence: true, on: :update,
            numericality: {only_integer: true, greater_than: 0}
  validates :editor_type, presence: true, inclusion: {in: FORMAT_TYPES},
            on: :update, length: {maximum: 255}

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:sorting_order, :course_module_element_id) }

  # class methods

  # instance methods
  def destroyable?
    true
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
