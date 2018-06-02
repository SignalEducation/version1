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
#  type                     :string
#  text_content             :text
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#

class ScenarioAnswerTemplate < ActiveRecord::Base

  # attr-accessible
  attr_accessible :course_module_element_id, :constructed_response_id,
                  :scenario_id, :scenario_question_id,
                  :sorting_order, :type

  # Constants
  FORMAT_TYPE = %w(text_editor spreadsheet_editor)


  # relationships
  belongs_to :course_module_element
  belongs_to :constructed_response
  belongs_to :scenario
  belongs_to :scenario_question

  # validation
  validates :course_module_element_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :constructed_response_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :constructed_response_scenario_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :constructed_response_question_id, presence: true,
            numericality: {only_integer: true, greater_than: 0}
  validates :sorting_order, presence: true
  validates :type, presence: true, inclusion: {in: FORMAT_TYPE}, length: {maximum: 255}

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:sorting_order, :course_module_element_id) }

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
