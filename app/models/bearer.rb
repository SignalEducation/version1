# frozen_string_literal: true

# == Schema Information
#
# Table name: bearers
#
#  id         :bigint           not null, primary key
#  name       :string           not null
#  slug       :string           not null
#  api_key    :string           not null
#  status     :integer          default("0"), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Model responsible to bearers management.
#
# ==== Examples
#
# Bearer.create(name: 'Learnsignal Front End', slug: 'learnsignal-frontend')
# => <Bearer id: 1, name: "Learnsignal Front End", slug: "learnsignal-frontend", api_key: "some_spi", status: "active">
# playon_subscriber.active? #=> true
# playon_subscriber.inactive! #=> true

class Bearer < ApplicationRecord
  enum status: { inactive: 0, active: 1 }

  before_validation :generate_api_key

  validates :name, :slug, :api_key, :status, presence: true
  validates :name, :slug, :api_key, uniqueness: true
  validates :slug, format: { without: /\s/, message: 'should not have whitespaces.' }

  def generate_api_key
    return if api_key.present?

    self.api_key = SecureRandom.hex
  end
end
