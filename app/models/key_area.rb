# frozen_string_literal: true

class KeyArea < ApplicationRecord
  # relationships
  belongs_to :group
  belongs_to :level
  has_many :courses, dependent: :restrict_with_error

  # validations
  validates :group_id, :name, presence: true
  validates :name, presence: true, uniqueness: {
    scope: :group_id,
    message: 'must be unique within the group'
  }
  # scopes
  scope :all_in_order, -> { order(:sorting_order, :group_id) }
  scope :all_active, -> { where(active: true) }

  def self.search(search)
    if search
      where('name ILIKE ?', "%#{search}%")
    else
      all_active.all_in_order
    end
  end

  def destroyable?
    true
  end
end
