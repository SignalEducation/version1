# frozen_string_literal: true

# == Schema Information
#
# Table name: constructed_responses
#
#  id                       :integer          not null, primary key
#  course_step_id :integer
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  time_allowed             :integer
#  destroyed_at             :datetime
#

class ConstructedResponse < ApplicationRecord
  # Constants

  # relationships
  belongs_to :course_step
  has_one :scenario, dependent: :restrict_with_error

  accepts_nested_attributes_for :scenario, reject_if: ->(attributes) { constructed_response_nested_scenario_text_is_blank?(attributes) }

  # validation
  validates :course_step_id, presence: true, on: :update,
                                       numericality: { only_integer: true, greater_than: 0 }

  # callbacks
  before_destroy :check_dependencies

  # scopes
  scope :all_in_order, -> { order(:course_step_id) }

  # class methods
  def self.constructed_response_nested_scenario_text_is_blank?(attributes)
    attributes['text_content'].blank?
  end

  # instance methods
  def destroyable?
    true
  end

  def add_an_empty_scenario
    build_scenario
    scenario.constructed_response_id = id
    scenario.add_an_empty_scenario_question
  end

  def duplicate
    new_constructed_response =
      deep_clone include: [
        :course_step,
        scenario: {
          scenario_questions: :scenario_answer_templates
        }
      ], validate: false

    new_constructed_response.
      course_step.update(name: "#{course_step.name} COPY",
                                   name_url: "#{course_step.name_url}_copy",
                                   active: false)
  end

  protected

  def check_dependencies
    return if destroyable?

    errors.add(:base, I18n.t('models.general.dependencies_exist'))
    false
  end
end
