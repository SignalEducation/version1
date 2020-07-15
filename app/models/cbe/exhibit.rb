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
    # concerns
    include CbeSupport

    # relationships
    belongs_to :section, class_name: 'Cbe::Section', foreign_key: 'cbe_section_id',
                         inverse_of: :exhibits
    belongs_to :scenario, class_name: 'Cbe::Scenario', foreign_key: 'cbe_scenario_id',
                          inverse_of: :exhibits

    # validations
    validates :name, :content, :cbe_scenario_id, presence: true
    validates :document, attachment_presence: true
    validates_attachment_content_type :document, content_type: %w[application/pdf text/csv]
  end
end
