# frozen_string_literal: true

# == Schema Information
#
# Table name: cbe_resources
#
#  id                    :bigint           not null, primary key
#  name                  :string
#  sorting_order         :integer
#  document_file_name    :string
#  document_content_type :string
#  document_file_size    :bigint
#  document_updated_at   :datetime
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  cbe_id                :bigint
#
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
