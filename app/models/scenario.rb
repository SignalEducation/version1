# == Schema Information
#
# Table name: scenarios
#
#  id                       :integer          not null, primary key
#  course_module_element_id :integer
#  constructed_response_id  :integer
#  sorting_order            :integer
#  text_content             :text
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#

class Scenario < ActiveRecord::Base

  # attr-accessible
  attr_accessible :course_module_element_id, :constructed_response_id, :sorting_order, :text_content,
                  :scenario_questions_attributes

  # Constants

  # relationships
  belongs_to :course_module_element
  belongs_to :constructed_response
  has_many :scenario_questions
  has_many :scenario_answer_templates

  accepts_nested_attributes_for :scenario_questions


  # validation
  validates :constructed_response_id, presence: true, on: :update,
            numericality: {only_integer: true, greater_than: 0}
  validates :text_content, presence: true, on: :update

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:course_module_element_id) }

  # class methods

  # instance methods
  def destroyable?
    false
  end

  def add_an_empty_scenario_question
    self.scenario_questions.build
    self.scenario_questions.last.scenario_id = self.id
    2.times do |number|
      self.scenario_questions.last.scenario_answer_templates.build(
          sorting_order: number + 1,
          editor_type: (number.odd? ? 'text_editor' : 'spreadsheet_editor')
      )
    end

 end

  protected

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

end
