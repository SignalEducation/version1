# frozen_string_literal: true

class Cbe::IntroductionPage < ApplicationRecord
  # relationships
  belongs_to :cbe

  # validations
  validates :title, :content, :cbe_id, presence: true
end
