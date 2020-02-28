# frozen_string_literal: true

# == Schema Information
#
# Table name: cbe_sections
#
#  id            :bigint           not null, primary key
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  name          :string
#  cbe_id        :bigint
#  score         :float
#  kind          :integer
#  sorting_order :integer
#  content       :text
#
class Cbe
  class Section < ApplicationRecord
    # relationships
    belongs_to :cbe
    has_many :questions, class_name: 'Cbe::Question', foreign_key: 'cbe_section_id',
                         inverse_of: :section, dependent: :destroy
    has_many :scenarios, class_name: 'Cbe::Scenario', foreign_key: 'cbe_section_id',
                         inverse_of: :section, dependent: :destroy

    # validations
    validates :name, :kind, :content, :cbe_id, presence: true

    # scopes
    scope :all_in_order, -> { order(:sorting_order) }

    # enums
    enum kind: { objective: 0, constructed_response: 1, objective_test_case: 2 }
  end
end
