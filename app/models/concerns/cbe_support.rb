# frozen_string_literal: true

module CbeSupport
  extend ActiveSupport::Concern

  included do
    scope :active,   -> { where(active: true) }
    scope :inactive, -> { where(active: false) }
  end

  def destroy
    self.destroyed_at = Time.zone.now
    self.active       = false
    inactive_children

    save
  end

  def inactive_children
    scenarios.map(&:destroy) if respond_to?(:scenarios)
    questions.map(&:destroy) if respond_to?(:questions)
  end
end
