# frozen_string_literal: true

class Cbe
  class Exhibit < ApplicationRecord
    # concerns
    include CbeSupport

    # relationships
    belongs_to :section, class_name: 'Cbe::Section', foreign_key: 'cbe_section_id',
                         inverse_of: :exhibits
    belongs_to :scenario, class_name: 'Cbe::Scenario', foreign_key: 'cbe_scenario_id',
                          inverse_of: :exhibits

    # validations
    validates :name, :content, :cbe_scenario_id, presence: true
    validates :document, attachment_presence: true
    validates_attachment_content_type :document, content_type: ['application/pdf', 'text/csv']
  end
end
