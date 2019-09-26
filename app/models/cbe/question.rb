# frozen_string_literal: true

class Cbe::Question < ApplicationRecord
  # enum
  include CbeQuestionTypes

  # relationships
  belongs_to :section, class_name: 'Cbe::Section', foreign_key: 'cbe_section_id',
                       inverse_of: :questions
  belongs_to :scenario, class_name: 'Cbe::Scenario', foreign_key: 'cbe_scenario_id', optional: true
  has_many :answers, class_name: 'Cbe::Answer', dependent: :destroy

  # validations
  validates :content, :kind, :score, presence: true
  validates :score, numericality: { greater_than_or_equal_to: 0 }
end
