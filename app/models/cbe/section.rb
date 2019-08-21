# frozen_string_literal: true

class Cbe::Section < ApplicationRecord
  # relationships
  belongs_to :cbe
  has_many :questions, class_name: 'Cbe::Question', foreign_key: 'cbe_section_id', dependent: :destroy

  # validations
  validates :name, :scenario_label, :scenario_description, :cbe_id, presence: true
end
