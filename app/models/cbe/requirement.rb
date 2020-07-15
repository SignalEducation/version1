# frozen_string_literal: true

class Cbe
  class Requirement < ApplicationRecord
    # concerns
    include CbeSupport

    # relationships
    belongs_to :section, class_name: 'Cbe::Section', foreign_key: 'cbe_section_id',
                         inverse_of: :requirements
    belongs_to :scenario, class_name: 'Cbe::Scenario', foreign_key: 'cbe_scenario_id',
                          inverse_of: :requirements

    # validations
    validates :name, :content, :kind, :cbe_section_id, :cbe_scenario_id, presence: true
    validates :score, numericality: { greater_than_or_equal_to: 0 }
  end
end
