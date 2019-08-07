# frozen_string_literal: true


class CbeSectionType < ApplicationRecord
    belongs_to :cbe, dependent: :destroy
end
