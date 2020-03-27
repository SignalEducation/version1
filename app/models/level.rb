# frozen_string_literal: true

# == Schema Information
#
# Table name: levels
#
#  id                           :bigint           not null, primary key
#  group_id                     :integer
#  name                         :string
#  name_url                     :string
#  active                       :boolean          default("false"), not null
#  highlight_colour             :string           default("#ef475d")
#  sorting_order                :integer
#  icon_label                   :string
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#  onboarding_course_subheading :text
#  onboarding_course_heading    :string
#
class Level < ApplicationRecord
  # relationships
  belongs_to :group
  has_many :courses

  # validations
  validates :group_id, :name, :name_url, :onboarding_course_heading, presence: true
  validates :name, :name_url, uniqueness: true

  # scopes
  scope :all_in_order, -> { order(:sorting_order, :group_id) }
  scope :all_active, -> { where(active: true) }

end
