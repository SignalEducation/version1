# frozen_string_literal: true

# == Schema Information
#
# Table name: cbe_requirements
#
#  id              :bigint           not null, primary key
#  name            :string
#  content         :text
#  score           :float
#  sorting_order   :integer
#  kind            :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  cbe_scenario_id :bigint
#  solution        :text
#
class Cbe
  class Requirement < ApplicationRecord
    enum kind: { requirement: 0, task: 1 }

    # relationships
    belongs_to :scenario, class_name: 'Cbe::Scenario', foreign_key: 'cbe_scenario_id',
                          inverse_of: :requirements

    # validations
    validates :name, :content, :kind, :sorting_order, :cbe_scenario_id, presence: true
    validates :score, :sorting_order, numericality: { greater_than_or_equal_to: 0 }

    # scopes
    scope :by_scenario, ->(scenario_id) { where(cbe_scenario_id: scenario_id).order(:sorting_order) }
  end
end
