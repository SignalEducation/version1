# frozen_string_literal: true

class Cbe::MultipleChoiceQuestion < ApplicationRecord
  belongs_to :cbe_section, class_name: 'Cbe::Section'
end
