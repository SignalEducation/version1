# frozen_string_literal: true

class SubCategory < ApplicationRecord
  belongs_to :category
  has_many :groups, dependent: :restrict_with_error
  has_many :exam_bodies, through: :groups

  validates :name, :name_url, presence: true
  validates :name_url, uniqueness: true
  validates :active, inclusion: { in: [true, false] }
end
