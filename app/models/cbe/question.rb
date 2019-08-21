# frozen_string_literal: true

class Cbe::Question < ApplicationRecord
  # relationships
  belongs_to :section, class_name: 'Cbe::Section', foreign_key: 'cbe_section_id'

  # enums
  enum kind: { multiple_choise: 0,
               drag_drop: 1 }
end
