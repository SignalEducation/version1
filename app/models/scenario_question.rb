# == Schema Information
#
# Table name: scenario_questions
#
#  id                       :integer          not null, primary key
#  course_module_element_id :integer
#  constructed_response_id  :integer
#  scenario_id              :integer
#  sorting_order            :integer
#  text_content             :text
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#

class ScenarioQuestion < ActiveRecord::Base

  # attr-accessible
  attr_accessible :course_module_element_id, :constructed_response_id,
                  :scenario_id, :sorting_order, :text_content, :scenario_answer_templates_attributes

  # Constants

  # relationships
  belongs_to :course_module_element
  belongs_to :constructed_response
  belongs_to :scenario
  has_many :scenario_answer_templates
  has_many :scenario_question_attempts

  accepts_nested_attributes_for :scenario_answer_templates, reject_if: lambda { |attributes| question_nested_answer_template_is_blank?(attributes) }

  # validation
  validates :scenario_id, presence: true, on: :update,
            numericality: {only_integer: true, greater_than: 0}
  validates :text_content, presence: true

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:sorting_order, :course_module_element_id) }

  # class methods
  def self.question_nested_answer_template_is_blank?(attributes)
    attributes['text_content'].blank?
  end


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
