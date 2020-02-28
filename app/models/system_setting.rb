# frozen_string_literal: true

# == Schema Information
#
# Table name: system_settings
#
#  id          :bigint           not null, primary key
#  environment :string
#  settings    :hstore
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class SystemSetting < ApplicationRecord
  validates :environment, :settings, presence: true
  validates :environment, uniqueness: true
end
