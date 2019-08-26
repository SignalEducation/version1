# frozen_string_literal: true

class Cbe::Section < ApplicationRecord
  # relationships
  belongs_to :cbe
  has_many :questions, class_name: 'Cbe::Question', foreign_key: 'cbe_section_id',
                       inverse_of: :section, dependent: :destroy
  has_many :scenarios, class_name: 'Cbe::Scenario', foreign_key: 'cbe_section_id',
                       inverse_of: :section, dependent: :destroy

  # validations
  #validates :name, :kind, :cbe_id, presence: true
  validates :name, :content, :cbe_id, presence: true

  # enums
  enum kind: { objective: 0, constructed_response: 1, objective_test_case: 2 }
end
