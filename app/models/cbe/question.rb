# frozen_string_literal: true

class Cbe
  class Question < ApplicationRecord
    # enum
    include CbeQuestionTypes

    # relationships
    belongs_to :section, class_name: 'Cbe::Section', foreign_key: 'cbe_section_id',
                         inverse_of: :questions
    belongs_to :scenario, class_name: 'Cbe::Scenario', foreign_key: 'cbe_scenario_id',
                          inverse_of: :questions, optional: true
    has_many :answers, class_name: 'Cbe::Answer', foreign_key: 'cbe_question_id',
                       inverse_of: :question, dependent: :destroy

    accepts_nested_attributes_for :answers

    # validations
    validates :content, :kind, :score, presence: true
    validates :score, numericality: { greater_than_or_equal_to: 0 }

    # scopes
    scope :without_scenario, -> { where(cbe_scenario_id: nil) }
    scope :with_scenario,    -> { where.not(cbe_scenario_id: nil) }
  end
end
