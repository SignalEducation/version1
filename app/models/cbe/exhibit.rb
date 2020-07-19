# frozen_string_literal: true

# == Schema Information
#
# Table name: cbe_exhibits
#
#  id                    :bigint           not null, primary key
#  name                  :string
#  content               :string
#  sorting_order         :integer
#  document_file_name    :string
#  document_content_type :string
#  document_file_size    :bigint
#  document_updated_at   :datetime
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#  cbe_section_id        :bigint
#  cbe_scenario_id       :bigint
#
class Cbe
  class Exhibit < ApplicationRecord
    enum kind: { pdf: 0, spreadsheet: 1 }

    # paper_clip
    has_attached_file :document, default_url: nil

    # relationships
    belongs_to :scenario, class_name: 'Cbe::Scenario', foreign_key: 'cbe_scenario_id',
                          inverse_of: :exhibits

    # validations
    validates :name, :cbe_scenario_id, presence: true
    validates :content,  presence: true, if: proc { |kind| kind.spreadsheet? }
    validates :document, attachment_presence: true, if: proc { |kind| kind.pdf? }
    validates_attachment_content_type :document, content_type: %w[application/pdf text/csv]
  end
end
