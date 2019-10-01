# frozen_string_literal: true

class Cbe
  class IntroductionPage < ApplicationRecord
    enum kind: { text: 0, agreement: 1 }
    # relationships
    belongs_to :cbe

    # validations
    validates :title, :content, :cbe_id, presence: true
  end
end
