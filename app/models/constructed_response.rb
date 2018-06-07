# == Schema Information
#
# Table name: constructed_responses
#
#  id                       :integer          not null, primary key
#  course_module_element_id :integer
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  time_allowed             :integer
#

class ConstructedResponse < ActiveRecord::Base

  # attr-accessible
  attr_accessible :course_module_element_id, :time_allowed, :scenarios_attributes

  # Constants

  # relationships
  belongs_to :course_module_element
  has_many :scenarios
  has_many :scenario_questions
  has_many :scenario_answer_templates

  accepts_nested_attributes_for :scenarios

  # validation
  validates :course_module_element_id, presence: true, on: :update,
            numericality: {only_integer: true, greater_than: 0}

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:course_module_element_id) }

  # class methods

  # instance methods
  def destroyable?
    false
  end

  def add_an_empty_scenario
    self.scenarios.build
    self.scenarios.last.constructed_response_id = self.id
    self.scenarios.last.scenario_questions.build(sorting_order: 1)
    self.scenarios.last.scenario_questions.last.scenario_answer_templates.build(sorting_order: 1)
  end

  protected

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

end
