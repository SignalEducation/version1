# frozen_string_literal: true

class Cbe::Scenario < ApplicationRecord
  # relationships
  belongs_to :section, class_name: 'Cbe::Section', foreign_key: 'cbe_section_id',
                       inverse_of: :scenarios
  has_many :questions, class_name: 'Cbe::Question', inverse_of: :scenario,
           dependent: :destroy

  # validations
  validates :content, :cbe_section_id, presence: true
end
