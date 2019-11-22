# frozen_string_literal: true

class Level < ApplicationRecord
  # relationships
  belongs_to :group
  has_many :subject_courses

  # validations
  validates :group_id, :name, :name_url, :onboarding_course_heading, presence: true
  validates :name, :name_url, uniqueness: true

  # scopes
  scope :all_in_order, -> { order(:sorting_order, :group_id) }
  scope :all_active, -> { where(active: true) }

end
