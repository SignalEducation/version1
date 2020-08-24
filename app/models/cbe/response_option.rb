# frozen_string_literal: true

class Cbe
  class ResponseOption < ApplicationRecord
    # enum
    enum kind: { open: 0, multiple_open: 1, spreadsheet: 2 }

    # relationships
    belongs_to :scenario, class_name: 'Cbe::Scenario', foreign_key: 'cbe_scenario_id',
                          inverse_of: :response_options, optional: true
    has_many :user_responses, class_name: 'Cbe::UserResponse', foreign_key: 'cbe_response_option_id',
                              inverse_of: :response_options, dependent: :restrict_with_error

    # validations
    validates :kind, :sorting_order, presence: true
    validates :quantity, presence: true, if: proc { |kind| kind.multiple_open? }
    validates :quantity, numericality: { greater_than_or_equal_to: 0 }, if: proc { |kind| kind.multiple_open? }

    # scopes
    scope :without_scenario, -> { where(cbe_scenario_id: nil) }
    scope :with_scenario,    -> { where.not(cbe_scenario_id: nil) }
    scope :by_section,       ->(section_id) { where(cbe_section_id: section_id).order(:sorting_order) }
    scope :by_scenario,      ->(scenario_id) { where(cbe_scenario_id: scenario_id).order(:sorting_order) }
    def formatted_kind
      case kind
      when 'open'
        'Word Processor'
      when 'multiple_open'
        'Slides'
      when 'spreadsheet'
        'Spreadsheet'
      end
    end
  end
end
