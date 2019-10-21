# frozen_string_literal: true

class Cbe
  class Resource < ApplicationRecord
    # relationships
    belongs_to :cbe

    # paper_clip
    has_attached_file :document, default_url: nil

    # validations
    validates :name, presence: true
    validates :document, attachment_presence: true
    validates_attachment_content_type :document, content_type: 'application/pdf'
  end
end
