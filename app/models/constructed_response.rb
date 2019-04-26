# == Schema Information
#
# Table name: constructed_responses
#
#  id                       :integer          not null, primary key
#  course_module_element_id :integer
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  time_allowed             :integer
#  destroyed_at             :datetime
#

class ConstructedResponse < ActiveRecord::Base
  # Constants

  # relationships
  belongs_to :course_module_element
  has_one :scenario

  accepts_nested_attributes_for :scenario, reject_if: lambda { |attributes| constructed_response_nested_scenario_text_is_blank?(attributes) }

  # validation
  validates :course_module_element_id, presence: true, on: :update,
            numericality: {only_integer: true, greater_than: 0}

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:course_module_element_id) }

  # class methods
  def self.constructed_response_nested_scenario_text_is_blank?(attributes)
    attributes['text_content'].blank?
  end

  # instance methods
  def destroyable?
    true
  end

  def add_an_empty_scenario
    self.build_scenario
    self.scenario.constructed_response_id = self.id
    self.scenario.add_an_empty_scenario_question
  end

  protected

  def check_dependencies
    unless self.destroyable?
      errors.add(:base, I18n.t('models.general.dependencies_exist'))
      false
    end
  end

end
