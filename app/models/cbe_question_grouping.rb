# frozen_string_literal: true

class CbeQuestionGrouping < ApplicationRecord
  belongs_to :cbe
  belongs_to :cbe_section
end