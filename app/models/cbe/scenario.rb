# frozen_string_literal: true

# == Schema Information
#
# Table name: cbe_scenarios
#
#  id             :bigint           not null, primary key
#  content        :string
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  cbe_section_id :bigint
#  name           :string
#  destroyed_at   :datetime
#  active         :boolean          default("true")
#
class Cbe
  class Scenario < ApplicationRecord
    # concerns
    include CbeSupport

    # relationships
    belongs_to :section, class_name: 'Cbe::Section', foreign_key: 'cbe_section_id',
                         inverse_of: :scenarios
    has_many :questions, class_name: 'Cbe::Question', foreign_key: 'cbe_scenario_id',
                         inverse_of: :scenario, dependent: :destroy

    has_many :exhibits, class_name: 'Cbe::Exhibit', foreign_key: 'cbe_scenario_id',
                        inverse_of: :scenario, dependent: :destroy

    has_many :requirements, class_name: 'Cbe::Requirement', foreign_key: 'cbe_scenario_id',
                            inverse_of: :scenario, dependent: :destroy

    has_many :response_options, class_name: 'Cbe::ResponseOption', foreign_key: 'cbe_scenario_id',
                                inverse_of: :scenario, dependent: :destroy

    # validations
    validates :name, :content, :cbe_section_id, presence: true
  end
end
