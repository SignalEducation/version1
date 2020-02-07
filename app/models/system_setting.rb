# frozen_string_literal: true

class SystemSetting < ApplicationRecord
  validates :environment, :settings, presence: true
  validates :environment, uniqueness: true
end
