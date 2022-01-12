# frozen_string_literal: true

class Category < ApplicationRecord
  has_many :sub_categories, dependent: :restrict_with_error
  has_many :groups, dependent: :restrict_with_error
  has_many :exam_bodies, through: :groups

  validates :name, :name_url, presence: true
  validates :name_url, uniqueness: true
  validates :active, inclusion: { in: [true, false] }

  scope :all_active, -> { where(active: true) }
end
